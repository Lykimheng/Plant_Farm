<?php

namespace Tests\Feature;

use App\Models\AppNotification;
use App\Models\Order;
use App\Models\Payment;
use App\Models\Plant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PayWayPaymentTest extends TestCase
{
    use RefreshDatabase;

    private const API_KEY = 'test-api-key';

    private User $user;
    private Plant $monstera;

    // what the fake PayWay answers to check-transaction
    private string $paywayStatus = 'PENDING';
    private ?float $paywayAmount = null;
    private bool $paywayKnowsTransaction = true;
    private ?array $paywayRejection = null;

    private array $purchases = [];
    private array $checks = [];
    private array $closes = [];

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.payway.base_url'    => 'https://checkout-sandbox.payway.com.kh',
            'services.payway.merchant_id' => 'ec000002',
            'services.payway.api_key'     => self::API_KEY,
            'services.payway.return_url'  => null,
            'services.payway.lifetime'    => 15,
        ]);

        $this->user = User::forceCreate([
            'name' => 'Test Customer',
            'email' => 'customer@example.test',
            'password' => 'secret123',
        ]);
        Sanctum::actingAs($this->user);

        // 2 × $18.00 + $1.50 standard delivery = $37.50
        $this->monstera = Plant::create([
            'image' => 'test.png',
            'name' => 'Monstera',
            'type' => 'Indoor',
            'type_plant' => 'indoorPlant',
            'price' => 18.00,
            'description' => 'Test plant.',
        ]);

        $this->fakePayWay();
    }

    public function test_khqr_payment_charges_the_server_total_and_is_signed(): void
    {
        $orderId = $this->placeOrder('khqr', claimedTotal: 0.01);

        $this->startPayment($orderId, 'khqr')
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'pending')
            ->assertJsonPath('payment.amount', 37.5)
            ->assertJsonPath('payment.qr_string', '00020101021230510016abaakhppxxx@abaa')
            ->assertJsonPath('payment.deeplink', 'abamobilebank://ababank.com?type=payway&qrcode=000201');

        $this->assertCount(1, $this->purchases);
        $sent = $this->purchases[0];

        $this->assertSame('37.50', $sent['amount']);
        $this->assertSame('USD', $sent['currency']);
        $this->assertSame('ec000002', $sent['merchant_id']);
        $this->assertSame('abapay_khqr_deeplink', $sent['payment_option']);
        $this->assertSame(Payment::sole()->tran_id, $sent['tran_id']);
        $this->assertSame(
            ['ios_scheme' => 'plantfarm://payway', 'android_scheme' => 'plantfarm://payway'],
            json_decode(base64_decode($sent['return_deeplink']), true)
        );
        $this->assertSame($this->purchaseHash($sent), $sent['hash']);
        $this->assertArrayNotHasKey('return_url', $sent);
    }

    public function test_the_api_url_from_abas_email_can_be_pasted_as_is(): void
    {
        config(['services.payway.base_url' => 'https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase']);
        $orderId = $this->placeOrder('khqr');

        $this->startPayment($orderId, 'khqr')->assertOk();
        $this->getJson("/api/orders/{$orderId}/payment")->assertOk();

        Http::assertSent(fn (Request $request) => $request->url() === 'https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/purchase');
        Http::assertSent(fn (Request $request) => $request->url() === 'https://checkout-sandbox.payway.com.kh/api/payment-gateway/v1/payments/check-transaction-2');
    }

    public function test_order_stays_unpaid_until_payway_approves(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');

        $this->getJson("/api/orders/{$orderId}/payment")
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'pending');

        $this->paywayStatus = 'APPROVED';

        $this->getJson("/api/orders/{$orderId}/payment")
            ->assertOk()
            ->assertJsonPath('payment_status', 'paid')
            ->assertJsonPath('payment.status', 'approved')
            ->assertJsonPath('payment.qr_string', null);

        $order = Order::find($orderId);
        $this->assertSame('paid', $order->payment_status);
        $this->assertNotNull($order->paid_at);
        $this->assertSame('753786', Payment::sole()->apv);
        $this->assertSame(1, AppNotification::where('type', 'paymentReceived')->count());

        $check = end($this->checks);
        $this->assertSame(
            base64_encode(hash_hmac('sha512', $check['req_time'].$check['merchant_id'].$check['tran_id'], self::API_KEY, true)),
            $check['hash']
        );
    }

    public function test_forged_callback_cannot_mark_an_order_paid(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');
        $tranId = Payment::sole()->tran_id;

        Sanctum::actingAs(User::forceCreate(['name' => 'Nobody', 'email' => 'x@example.test', 'password' => 'secret123']));

        $this->postJson('/api/payway/callback', [
            'tran_id' => $tranId,
            'apv' => '123456',
            'status' => 0,
            'payment_amount' => 37.5,
        ])->assertOk();

        $this->assertSame('unpaid', Order::find($orderId)->payment_status);
        $this->assertSame('pending', Payment::sole()->status);
    }

    public function test_callback_marks_the_order_paid_once_payway_confirms(): void
    {
        $orderId = $this->placeOrder('aba');
        $this->startPayment($orderId, 'aba');

        $this->paywayStatus = 'APPROVED';

        $this->postJson('/api/payway/callback', ['tran_id' => Payment::sole()->tran_id, 'status' => 0])
            ->assertOk()
            ->assertJson(['success' => true]);

        $this->assertSame('paid', Order::find($orderId)->payment_status);

        $this->postJson('/api/payway/callback', ['tran_id' => 'PF-UNKNOWN'])->assertNotFound();
    }

    public function test_declined_payment_leaves_the_order_unpaid(): void
    {
        $orderId = $this->placeOrder('card');
        $this->startPayment($orderId, 'card');

        $this->paywayStatus = 'DECLINED';

        $this->getJson("/api/orders/{$orderId}/payment")
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'declined');
    }

    public function test_cancelling_closes_the_payway_transaction(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');
        $tranId = Payment::sole()->tran_id;

        $this->postJson("/api/orders/{$orderId}/payment/cancel")
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'cancelled');

        $this->assertSame([$tranId], $this->closes);
        $this->assertSame('pending', Order::find($orderId)->status);
    }

    public function test_cancel_finds_a_payment_that_just_went_through(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');

        $this->paywayStatus = 'APPROVED';

        $this->postJson("/api/orders/{$orderId}/payment/cancel")
            ->assertOk()
            ->assertJsonPath('payment_status', 'paid')
            ->assertJsonPath('payment.status', 'approved');

        $this->assertSame([], $this->closes);
    }

    public function test_approval_for_a_different_amount_is_not_accepted(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');

        $this->paywayStatus = 'APPROVED';
        $this->paywayAmount = 0.01;

        $this->getJson("/api/orders/{$orderId}/payment")
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'failed');
    }

    public function test_switching_method_closes_the_previous_transaction(): void
    {
        $orderId = $this->placeOrder('aba');
        $this->startPayment($orderId, 'aba');
        $first = Payment::sole()->tran_id;

        $this->startPayment($orderId, 'khqr')
            ->assertOk()
            ->assertJsonPath('payment.method', 'khqr')
            ->assertJsonPath('payment.status', 'pending');

        $this->assertSame([$first], $this->closes);
        $this->assertSame('cancelled', Payment::where('tran_id', $first)->value('status'));
        $this->assertSame('khqr', Order::find($orderId)->payment_method);
        $this->assertCount(2, $this->purchases);
    }

    public function test_an_attempt_paid_meanwhile_is_not_charged_again(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');

        $this->paywayStatus = 'APPROVED';

        $this->startPayment($orderId, 'card')
            ->assertOk()
            ->assertJsonPath('payment_status', 'paid')
            ->assertJsonPath('payment.method', 'khqr');

        $this->assertCount(1, $this->purchases);
        $this->assertSame(1, Payment::count());
    }

    public function test_card_payment_returns_payways_card_form(): void
    {
        $orderId = $this->placeOrder('card');

        $this->startPayment($orderId, 'card')
            ->assertOk()
            ->assertJsonPath('payment.method', 'card')
            ->assertJsonPath('payment.checkout_html', '<html><title>PayWay - Checkout</title></html>')
            ->assertJsonPath('payment.checkout_base_url', 'https://checkout-sandbox.payway.com.kh/')
            ->assertJsonPath('payment.qr_string', null);

        $this->assertSame('cards', $this->purchases[0]['payment_option']);
        $this->assertSame($this->purchaseHash($this->purchases[0]), $this->purchases[0]['hash']);
    }

    public function test_unpaid_attempt_expires_after_its_lifetime(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');

        $this->travel(18)->minutes();

        $this->getJson("/api/orders/{$orderId}/payment")
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'expired');
    }

    public function test_transaction_payway_has_not_seen_yet_stays_pending(): void
    {
        $orderId = $this->placeOrder('card');
        $this->startPayment($orderId, 'card');

        $this->paywayKnowsTransaction = false;

        $this->getJson("/api/orders/{$orderId}/payment")
            ->assertOk()
            ->assertJsonPath('payment_status', 'unpaid')
            ->assertJsonPath('payment.status', 'pending');
    }

    public function test_another_customers_order_cannot_be_paid_or_read(): void
    {
        $orderId = $this->placeOrder('khqr');

        Sanctum::actingAs(User::forceCreate(['name' => 'Other', 'email' => 'other@example.test', 'password' => 'secret123']));

        $this->startPayment($orderId, 'khqr')->assertNotFound();
        $this->getJson("/api/orders/{$orderId}/payment")->assertNotFound();
        $this->postJson("/api/orders/{$orderId}/payment/cancel")->assertNotFound();
        $this->assertSame([], $this->purchases);
    }

    public function test_paid_order_cannot_be_cancelled_by_the_customer(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');
        $this->paywayStatus = 'APPROVED';
        $this->getJson("/api/orders/{$orderId}/payment");

        $this->postJson("/api/orders/{$orderId}/cancel")
            ->assertStatus(422)
            ->assertJson(['success' => false]);

        $this->assertSame('pending', Order::find($orderId)->status);
    }

    public function test_cancelling_an_order_closes_its_open_payment(): void
    {
        $orderId = $this->placeOrder('khqr');
        $this->startPayment($orderId, 'khqr');

        $this->postJson("/api/orders/{$orderId}/cancel")->assertOk();

        $this->assertSame('cancelled', Order::find($orderId)->status);
        $this->assertSame('cancelled', Payment::sole()->status);
        $this->assertCount(1, $this->closes);

        $this->startPayment($orderId, 'khqr')->assertStatus(422);
    }

    public function test_cash_on_delivery_orders_never_reach_payway(): void
    {
        $orderId = $this->placeOrder('cod');

        $this->assertSame('cod', Order::find($orderId)->payment_method);
        $this->startPayment($orderId, 'cod')->assertStatus(422);
        $this->assertSame([], $this->purchases);
    }

    public function test_unknown_payment_method_is_rejected_at_checkout(): void
    {
        $this->postJson('/api/orders', $this->orderBody('bitcoin'))->assertStatus(422);

        $this->assertSame(0, Order::count());
    }

    public function test_missing_payway_keys_are_reported_plainly(): void
    {
        config(['services.payway.api_key' => null]);
        $orderId = $this->placeOrder('khqr');

        $this->startPayment($orderId, 'khqr')
            ->assertStatus(503)
            ->assertJson(['success' => false]);
    }

    public function test_payway_rejection_keeps_the_order_unpaid(): void
    {
        $this->paywayRejection = ['code' => 6, 'message' => 'wrong domain'];
        $orderId = $this->placeOrder('khqr');

        $this->startPayment($orderId, 'khqr')
            ->assertStatus(502)
            ->assertJson(['success' => false]);

        $this->assertSame('failed', Payment::sole()->status);
        $this->assertSame('unpaid', Order::find($orderId)->payment_status);
    }

    // MARK: - Helpers

    private function placeOrder(string $method, float $claimedTotal = 37.50): int
    {
        $response = $this->postJson('/api/orders', $this->orderBody($method, $claimedTotal))->assertOk();

        return (int) $response->json('order_id');
    }

    private function orderBody(string $method, float $claimedTotal = 37.50): array
    {
        return [
            'order_number' => 'PF-PAY-'.random_int(1000, 9999),
            'delivery_address' => 'No. 42, St. 271, Phnom Penh',
            'delivery_option' => 'standard',
            'payment_method' => $method,
            'total' => $claimedTotal,
            'items' => [['plant_id' => $this->monstera->id, 'plant_name' => 'Monstera', 'price' => 18.00, 'quantity' => 2]],
        ];
    }

    private function startPayment(int $orderId, string $method)
    {
        return $this->postJson("/api/orders/{$orderId}/payments", ['method' => $method]);
    }

    /** The signature as PayWay's docs define it, computed independently of the app code. */
    private function purchaseHash(array $fields): string
    {
        $order = [
            'req_time', 'merchant_id', 'tran_id', 'amount', 'items', 'shipping',
            'firstname', 'lastname', 'email', 'phone', 'type', 'payment_option',
            'return_url', 'cancel_url', 'continue_success_url', 'return_deeplink',
            'currency', 'custom_fields', 'return_params', 'payout', 'lifetime',
            'additional_params', 'google_pay_token', 'skip_success_page',
        ];

        $data = implode('', array_map(fn (string $field) => $fields[$field] ?? '', $order));

        return base64_encode(hash_hmac('sha512', $data, self::API_KEY, true));
    }

    private function fakePayWay(): void
    {
        Http::fake(function (Request $request) {
            $path = parse_url($request->url(), PHP_URL_PATH);

            if ($this->paywayRejection) {
                return Http::response(['status' => $this->paywayRejection]);
            }

            if (str_ends_with($path, '/payments/purchase')) {
                $fields = collect($request->data())->mapWithKeys(fn ($part) => [$part['name'] => $part['contents']])->all();
                $this->purchases[] = $fields;

                if ($fields['payment_option'] === 'cards') {
                    return Http::response('<html><title>PayWay - Checkout</title></html>', 200, ['Content-Type' => 'text/html']);
                }

                return Http::response([
                    'status' => ['code' => '00', 'message' => 'Success!', 'tran_id' => $fields['tran_id']],
                    'qr_string' => '00020101021230510016abaakhppxxx@abaa',
                    'abapay_deeplink' => 'abamobilebank://ababank.com?type=payway&qrcode=000201',
                    'checkout_qr_url' => 'https://checkout-uat.payway.com.kh/qr',
                ]);
            }

            if (str_ends_with($path, '/payments/check-transaction-2')) {
                $this->checks[] = $request->data();

                if (! $this->paywayKnowsTransaction) {
                    return Http::response(['status' => ['code' => 6, 'message' => 'Transaction not found', 'tran_id' => $request['tran_id']]]);
                }

                $amount = $this->paywayAmount ?? (float) Payment::where('tran_id', $request['tran_id'])->value('amount');

                return Http::response([
                    'data' => [
                        'payment_status_code' => ['APPROVED' => 0, 'PENDING' => 2, 'DECLINED' => 3][$this->paywayStatus] ?? 7,
                        'total_amount' => $amount,
                        'original_amount' => $amount,
                        'payment_amount' => $amount,
                        'payment_currency' => 'USD',
                        'apv' => $this->paywayStatus === 'APPROVED' ? '753786' : '',
                        'payment_status' => $this->paywayStatus,
                        'transaction_date' => now()->format('Y-m-d H:i:s'),
                    ],
                    'status' => ['code' => '00', 'message' => 'Success!', 'tran_id' => $request['tran_id']],
                ]);
            }

            if (str_ends_with($path, '/payments/close-transaction')) {
                $this->closes[] = $request['tran_id'];

                return Http::response(['status' => ['code' => '00', 'message' => 'Success!', 'tran_id' => $request['tran_id']]]);
            }

            return Http::response('unexpected PayWay call', 500);
        });
    }
}
