<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Keeps orders in step with their PayWay transactions. An order is marked
 * paid only from PayWay's own check-transaction answer, never from anything
 * the app sends or from the body of a callback.
 */
class OrderPayments
{
    public const METHODS = ['khqr', 'card'];

    // the app's prices are in dollars
    private const CURRENCY = 'USD';

    // PayWay hands the customer back to the app through this link
    private const APP_RETURN_LINK = 'plantfarm://payway';

    // a payment can still settle shortly after its lifetime runs out
    private const GRACE_MINUTES = 2;

    public function __construct(private readonly PayWay $payway) {}

    public function isAvailable(): bool
    {
        return $this->payway->isConfigured();
    }

    /**
     * Opens a PayWay transaction for the order's server-side total. Earlier
     * attempts are checked and closed first, so an old QR code can't be paid
     * as well. If one of them turns out to be paid, that one is returned and
     * no new transaction is made.
     *
     * @return array{0: Payment, 1: ?string} the attempt, and for cards PayWay's card form
     */
    public function start(Order $order, string $method, User $customer): array
    {
        if ($paid = $this->settle($order)) {
            return [$paid, null];
        }

        $payment = $order->payments()->create([
            'tran_id'    => $this->newTransactionId(),
            'method'     => $method,
            'amount'     => $order->total,
            'currency'   => self::CURRENCY,
            'status'     => 'pending',
            'expires_at' => now()->addMinutes($this->lifetime()),
        ]);

        $fields = $this->purchaseFields($order, $payment, $customer);
        $cardForm = null;

        try {
            if ($method === 'card') {
                $cardForm = $this->payway->createCardCheckout($fields);
            } else {
                $payment->update($this->payway->createQrPayment($fields));
            }
        } catch (PayWayException $e) {
            $payment->update(['status' => 'failed']);

            throw $e;
        }

        $order->update(['payment_method' => $method]);

        return [$payment, $cardForm];
    }

    /** Asks PayWay how a pending attempt went and records the answer. */
    public function refresh(Payment $payment): Payment
    {
        if (! $payment->isPending()) {
            return $payment;
        }

        $result = $this->payway->check($payment->tran_id);

        return DB::transaction(function () use ($payment, $result) {
            // a callback and the app can ask at the same moment
            $payment = Payment::lockForUpdate()->findOrFail($payment->id);

            if (! $payment->isPending()) {
                return $payment;
            }

            if (($result['status'] ?? null) === 'APPROVED') {
                return $this->approve($payment, $result);
            }

            $status = match ($result['status'] ?? null) {
                'DECLINED'  => 'declined',
                'CANCELLED' => 'cancelled',
                'REFUNDED'  => 'refunded',
                default     => now()->subMinutes(self::GRACE_MINUTES)->greaterThan($payment->expires_at) ? 'expired' : 'pending',
            };

            if ($status !== 'pending') {
                $payment->update(['status' => $status]);
            }

            return $payment;
        });
    }

    /**
     * Closes a pending attempt at PayWay so it can't be paid any more. Only
     * recorded as cancelled once PayWay has closed it: otherwise the customer
     * could still pay a transaction this server had stopped watching.
     */
    public function cancel(Payment $payment): Payment
    {
        $payment = $this->refresh($payment);

        if (! $payment->isPending()) {
            return $payment;
        }

        try {
            $this->payway->close($payment->tran_id);
        } catch (PayWayException $e) {
            // it may have been paid between the check and the close
            $payment = $this->refresh($payment);

            if (! $payment->isPending()) {
                return $payment;
            }

            throw $e;
        }

        $payment->update(['status' => 'cancelled']);

        return $payment;
    }

    /** Closes every open attempt; returns the approved one if the order was paid after all. */
    public function settle(Order $order): ?Payment
    {
        foreach ($order->payments()->where('status', 'pending')->get() as $payment) {
            $payment = $this->cancel($payment);

            if ($payment->status === 'approved') {
                return $payment;
            }
        }

        return null;
    }

    // MARK: - Helpers

    private function approve(Payment $payment, array $result): Payment
    {
        // PayWay reports the amount the transaction was created for; it has to be this order's total
        if (abs($result['amount'] - $payment->amount) > 0.001) {
            Log::critical('PayWay approved a transaction for a different amount than the order', [
                'tran_id'      => $payment->tran_id,
                'order_id'     => $payment->order_id,
                'expected'     => $payment->amount,
                'payway_total' => $result['amount'],
            ]);
            $payment->update(['status' => 'failed']);

            return $payment;
        }

        $payment->update(['status' => 'approved', 'apv' => $result['apv'], 'paid_at' => now()]);

        $order = Order::lockForUpdate()->findOrFail($payment->order_id);

        if ($order->payment_status !== 'paid') {
            // saved through the model so OrderObserver tells the customer
            $order->payment_status = 'paid';
            $order->payment_method = $payment->method;
            $order->paid_at = now();
            $order->save();
        }

        return $payment;
    }

    private function purchaseFields(Order $order, Payment $payment, User $customer): array
    {
        $items = $order->items->map(fn ($item) => [
            'name'     => $item->plant_name,
            'quantity' => (int) $item->quantity,
            'price'    => round((float) $item->price, 2),
        ])->all();

        $delivery = round($order->total - $order->items->sum(fn ($item) => $item->price * $item->quantity), 2);
        if ($delivery > 0) {
            $items[] = ['name' => 'Delivery', 'quantity' => 1, 'price' => $delivery];
        }

        [$firstName, $lastName] = $this->nameParts($customer->name);
        $returnUrl = config('services.payway.return_url');

        return array_filter([
            'tran_id'         => $payment->tran_id,
            'amount'          => number_format($payment->amount, 2, '.', ''),
            'items'           => base64_encode(json_encode(array_slice($items, 0, 50))),
            'firstname'       => $firstName,
            'lastname'        => $lastName,
            'email'           => strlen($customer->email) <= 50 ? $customer->email : '',
            'return_url'      => filled($returnUrl) ? base64_encode($returnUrl) : '',
            'return_deeplink' => base64_encode(json_encode([
                'ios_scheme'     => self::APP_RETURN_LINK,
                'android_scheme' => self::APP_RETURN_LINK,
            ])),
            'currency'        => $payment->currency,
            'lifetime'        => $this->lifetime(),
        ], fn ($value) => $value !== '' && $value !== null);
    }

    /** PayWay rejects names it can't read, so only plain Latin names are passed on. */
    private function nameParts(string $name): array
    {
        $name = trim(preg_replace('/\s+/', ' ', $name));

        if (! preg_match("/^[A-Za-z][A-Za-z .'-]*$/", $name)) {
            return ['', ''];
        }

        $parts = explode(' ', $name, 2);

        return [substr($parts[0], 0, 100), substr($parts[1] ?? '', 0, 100)];
    }

    private function newTransactionId(): string
    {
        // unique across databases too: the sandbox merchant keeps every id it has seen
        return 'PF'.now('UTC')->format('ymdHis').random_int(100, 999);
    }

    private function lifetime(): int
    {
        return max(3, (int) config('services.payway.lifetime', 15));
    }
}
