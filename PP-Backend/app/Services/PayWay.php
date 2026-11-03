<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;

/**
 * ABA PayWay's checkout API (https://developer.payway.com.kh). Every request
 * is signed with the merchant's API key, which is why the app talks to this
 * server and never to PayWay directly.
 */
class PayWay
{
    private const PURCHASE = 'api/payment-gateway/v1/payments/purchase';
    private const CHECK = 'api/payment-gateway/v1/payments/check-transaction-2';
    private const CLOSE = 'api/payment-gateway/v1/payments/close-transaction';

    // PayWay signs the purchase fields concatenated in exactly this order
    private const PURCHASE_HASH_FIELDS = [
        'req_time', 'merchant_id', 'tran_id', 'amount', 'items', 'shipping',
        'firstname', 'lastname', 'email', 'phone', 'type', 'payment_option',
        'return_url', 'cancel_url', 'continue_success_url', 'return_deeplink',
        'currency', 'custom_fields', 'return_params', 'payout', 'lifetime',
        'additional_params', 'google_pay_token', 'skip_success_page',
    ];

    private array $config;

    public function __construct(?array $config = null)
    {
        $this->config = $config ?? config('services.payway');
    }

    public function isConfigured(): bool
    {
        return filled($this->config['merchant_id'] ?? null) && filled($this->config['api_key'] ?? null);
    }

    public function baseUrl(): string
    {
        // ABA's email gives the full purchase URL; the API paths are added here
        $url = preg_replace('#/api/.*$#i', '', trim((string) $this->config['base_url']));

        return rtrim($url, '/').'/';
    }

    /**
     * One transaction payable both ways: the KHQR string to scan with any
     * KHQR bank app, and the link that opens ABA Mobile on the payment.
     *
     * @return array{qr_string: string, deeplink: string}
     */
    public function createQrPayment(array $fields): array
    {
        $body = $this->purchase($fields + ['payment_option' => 'abapay_khqr_deeplink'])->json();

        $this->assertSuccess($body);

        if (blank($body['qr_string'] ?? null)) {
            throw new PayWayException('PayWay answered without a KHQR code.');
        }

        return [
            'qr_string' => $body['qr_string'],
            'deeplink'  => (string) ($body['abapay_deeplink'] ?? ''),
        ];
    }

    /** PayWay's own card form, as the HTML page it answers with. */
    public function createCardCheckout(array $fields): string
    {
        $response = $this->purchase($fields + ['payment_option' => 'cards']);

        // a rejected request comes back as JSON instead of the page
        if (is_array($body = $response->json())) {
            $this->assertSuccess($body);
        }

        if (! $response->successful() || blank($response->body())) {
            throw new PayWayException("PayWay's card form didn't load (HTTP {$response->status()}).");
        }

        return $response->body();
    }

    /**
     * PayWay's own record of a transaction: APPROVED, PENDING, DECLINED,
     * REFUNDED or CANCELLED, plus the amount it was created for. Null when
     * PayWay has no transaction with that id.
     *
     * @return array{status: string, amount: float, apv: ?string}|null
     */
    public function check(string $tranId): ?array
    {
        $body = $this->signedPost(self::CHECK, $tranId);
        $code = (string) ($body['status']['code'] ?? '');

        // code 6 also means "wrong domain", so the message tells them apart
        if ($code === '6' && str_contains(strtolower($body['status']['message'] ?? ''), 'not found')) {
            return null;
        }

        $this->assertSuccess($body);

        return [
            'status' => strtoupper((string) ($body['data']['payment_status'] ?? '')),
            'amount' => (float) ($body['data']['original_amount'] ?? 0),
            'apv'    => filled($body['data']['apv'] ?? null) ? (string) $body['data']['apv'] : null,
        ];
    }

    /** Stops a transaction from accepting payment. False if PayWay has no such transaction. */
    public function close(string $tranId): bool
    {
        $body = $this->signedPost(self::CLOSE, $tranId);

        if ((string) ($body['status']['code'] ?? '') === '5') {
            return false;
        }

        $this->assertSuccess($body);

        return true;
    }

    // MARK: - Requests

    private function purchase(array $fields): Response
    {
        $fields = ['req_time' => $this->requestTime(), 'merchant_id' => $this->config['merchant_id']] + $fields;
        $fields = array_map('strval', $fields);

        $fields['hash'] = $this->sign(implode('', array_map(
            fn (string $name) => $fields[$name] ?? '',
            self::PURCHASE_HASH_FIELDS
        )));

        return $this->send(fn () => Http::timeout(20)->asMultipart()->post($this->baseUrl().self::PURCHASE, $fields));
    }

    private function signedPost(string $path, string $tranId): array
    {
        $fields = [
            'req_time'    => $this->requestTime(),
            'merchant_id' => (string) $this->config['merchant_id'],
            'tran_id'     => $tranId,
        ];
        $fields['hash'] = $this->sign(implode('', $fields));

        $response = $this->send(fn () => Http::timeout(15)->acceptJson()->asJson()->post($this->baseUrl().$path, $fields));

        return $response->json()
            ?? throw new PayWayException("PayWay sent an unreadable reply (HTTP {$response->status()}).");
    }

    private function send(callable $request): Response
    {
        try {
            return $request();
        } catch (ConnectionException $e) {
            throw new PayWayException("Couldn't reach PayWay: {$e->getMessage()}");
        }
    }

    private function sign(string $data): string
    {
        return base64_encode(hash_hmac('sha512', $data, (string) $this->config['api_key'], true));
    }

    private function requestTime(): string
    {
        return now('UTC')->format('YmdHis');
    }

    private function assertSuccess(?array $body): void
    {
        $code = (string) ($body['status']['code'] ?? '');

        if ($code === '00' || $code === '0') {
            return;
        }

        $message = (string) ($body['status']['message'] ?? 'PayWay rejected the request.');

        throw new PayWayException("PayWay error {$code}: {$message}", $code);
    }
}
