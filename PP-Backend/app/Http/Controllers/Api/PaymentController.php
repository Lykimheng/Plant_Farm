<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use App\Services\OrderPayments;
use App\Services\PayWay;
use App\Services\PayWayException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * Paying an order through ABA PayWay. The app starts a payment and then asks
 * this server how it went, and the server asks PayWay. Nothing the app sends
 * can mark an order paid.
 */
class PaymentController extends Controller
{
    public function __construct(
        private readonly OrderPayments $payments,
        private readonly PayWay $payway,
    ) {}

    public function store(Request $request, int $order)
    {
        $method = (string) $request->input('method');

        if (! in_array($method, OrderPayments::METHODS, true)) {
            return $this->fail('Choose ABA KHQR or a card to pay online.', 422);
        }

        $found = $request->user()->orders()->with('items')->find($order);

        if (! $found) {
            return $this->fail('Order not found.', 404);
        }

        if ($found->payment_status === 'paid') {
            return $this->state($found);
        }

        if (in_array($found->status, ['cancelled', 'rejected'], true)) {
            return $this->fail('This order was cancelled, so it can no longer be paid.', 422);
        }

        if (! $this->payments->isAvailable()) {
            Log::error('PayWay is not configured: set PAYWAY_MERCHANT_ID and PAYWAY_API_KEY in .env');

            return $this->fail("Online payment isn't available right now. Please choose cash on delivery.", 503);
        }

        try {
            [$payment, $cardForm] = $this->payments->start($found, $method, $request->user());
        } catch (PayWayException $e) {
            $this->logFailure('start', $found, $e);

            return $this->fail("We couldn't start the payment with ABA PayWay. Please try again or choose another way to pay.", 502);
        }

        return $this->state($found->refresh(), $payment, $cardForm);
    }

    /** The latest attempt, freshly checked with PayWay while it's still open. */
    public function show(Request $request, int $order)
    {
        $found = $request->user()->orders()->find($order);

        if (! $found) {
            return $this->fail('Order not found.', 404);
        }

        $payment = $found->payments()->latest('id')->first();

        if ($payment?->isPending()) {
            try {
                $payment = $this->payments->refresh($payment);
            } catch (PayWayException $e) {
                // answer with what's known; the app asks again in a moment
                $this->logFailure('check', $found, $e);
            }
        }

        return $this->state($found->refresh(), $payment);
    }

    public function cancel(Request $request, int $order)
    {
        $found = $request->user()->orders()->find($order);

        if (! $found) {
            return $this->fail('Order not found.', 404);
        }

        $payment = $found->payments()->latest('id')->first();

        if ($payment?->isPending()) {
            try {
                $payment = $this->payments->cancel($payment);
            } catch (PayWayException $e) {
                $this->logFailure('cancel', $found, $e);

                return $this->fail("We couldn't cancel the payment with ABA PayWay. Please try again.", 502);
            }
        }

        return $this->state($found->refresh(), $payment);
    }

    /**
     * PayWay's pushback after a payment. Anyone could post here, so the body
     * is only a hint about which transaction to go and check with PayWay.
     */
    public function callback(Request $request)
    {
        $payment = Payment::where('tran_id', (string) $request->input('tran_id'))->first();

        if (! $payment) {
            return $this->fail('Unknown transaction.', 404);
        }

        try {
            $this->payments->refresh($payment);
        } catch (PayWayException $e) {
            $this->logFailure('callback check', $payment->order, $e);

            return $this->fail('Could not confirm the payment yet.', 503);
        }

        return response()->json(['success' => true]);
    }

    private function state(Order $order, ?Payment $payment = null, ?string $cardForm = null)
    {
        $payment ??= $order->payments()->latest('id')->first();
        $open = $payment?->isPending() ?? false;

        return response()->json([
            'success'        => true,
            'payment_status' => $order->payment_status,
            'payment'        => $payment ? [
                'tran_id'           => $payment->tran_id,
                'method'            => $payment->method,
                'status'            => $payment->status,
                'amount'            => (float) $payment->amount,
                'currency'          => $payment->currency,
                'expires_at'        => $payment->expires_at->copy()->utc()->format('Y-m-d H:i:s'),
                'deeplink'          => $open ? $payment->deeplink : null,
                'qr_string'         => $open ? $payment->qr_string : null,
                'checkout_html'     => $open ? $cardForm : null,
                'checkout_base_url' => $open && $cardForm ? $this->payway->baseUrl() : null,
            ] : null,
        ]);
    }

    private function fail(string $message, int $status)
    {
        return response()->json(['success' => false, 'message' => $message], $status);
    }

    private function logFailure(string $action, ?Order $order, PayWayException $e): void
    {
        $hint = match ($e->payWayCode) {
            '6'     => "PayWay doesn't recognise this server: ask ABA to whitelist its public IP address",
            '1', '5' => 'PayWay rejected the signature: check PAYWAY_MERCHANT_ID and PAYWAY_API_KEY',
            '81'    => 'PAYWAY_RETURN_URL is not whitelisted by ABA',
            default => null,
        };

        Log::error("PayWay {$action} failed", array_filter([
            'order_id' => $order?->id,
            'error'    => $e->getMessage(),
            'hint'     => $hint,
        ]));
    }
}
