<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Plant;
use App\Services\OrderPayments;
use App\Services\PayWayException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Throwable;

class OrderController extends Controller
{
    private const DELIVERY_FEES = ['standard' => 1.50, 'express' => 2.00];

    // khqr and card are paid through ABA PayWay after the order is placed
    private const PAYMENT_METHODS = ['khqr', 'card', 'cod'];

    public function index(Request $request)
    {
        $orders = $request->user()->orders()
            ->with('items')
            ->orderByDesc('created_at')
            ->get();

        // resolve images for every referenced plant in one query
        $images = Plant::whereIn('id', $orders->pluck('items.*.plant_id')->flatten()->unique())
            ->pluck('image', 'id');

        $payload = $orders->map(fn (Order $order) => [
            'id'               => (int) $order->id,
            'user_id'          => (int) $order->user_id,
            'order_number'     => $order->order_number,
            'status'           => $order->status,
            'total'            => (float) $order->total,
            'delivery_address' => $order->delivery_address,
            'payment_method'   => $order->payment_method,
            'payment_status'   => $order->payment_status,
            'created_at'       => optional($order->created_at)->format('Y-m-d H:i:s'),
            'items'            => $order->items->map(fn (OrderItem $item) => [
                'id'         => (int) $item->id,
                'plant_id'   => (int) $item->plant_id,
                'plant_name' => $item->plant_name,
                'price'      => (float) $item->price,
                'quantity'   => (int) $item->quantity,
                'image'      => filled($images[$item->plant_id] ?? null)
                    ? url('uploads/plants/'.rawurlencode($images[$item->plant_id]))
                    : '',
            ])->values(),
        ]);

        return response()->json([
            'success' => true,
            'orders'  => $payload,
        ]);
    }

    public function store(Request $request)
    {
        $userId      = $request->user()->id;
        $orderNumber = $this->stringInput($request, 'order_number');
        $address     = $this->stringInput($request, 'delivery_address');
        $items       = $request->input('items', []);
        $delivery    = $this->stringInput($request, 'delivery_option') ?: 'standard';
        $payment     = $this->stringInput($request, 'payment_method') ?: 'cod';

        if ($orderNumber === '' || empty($items) || ! is_array($items)) {
            return response()->json([
                'success' => false,
                'message' => 'Missing required fields.',
            ], 422);
        }

        if (! array_key_exists($delivery, self::DELIVERY_FEES)) {
            return response()->json([
                'success' => false,
                'message' => 'Unknown delivery option.',
            ], 422);
        }

        if (! in_array($payment, self::PAYMENT_METHODS, true)) {
            return response()->json([
                'success' => false,
                'message' => 'Unknown payment method.',
            ], 422);
        }

        // prices come from the database; the total and prices the app sends are ignored
        $lines = [];
        $subtotal = 0.0;

        foreach ($items as $item) {
            $plant    = Plant::find((int) ($item['plant_id'] ?? 0));
            $quantity = (int) ($item['quantity'] ?? 0);

            if (! $plant || $quantity < 1) {
                return response()->json([
                    'success' => false,
                    'message' => 'An item in your cart is no longer available.',
                ], 422);
            }

            $price = $plant->discount_price !== null && $plant->discount_price < $plant->price
                ? $plant->discount_price
                : $plant->price;

            $lines[] = ['plant' => $plant, 'price' => $price, 'quantity' => $quantity];
            $subtotal += $price * $quantity;
        }

        $total = round($subtotal + self::DELIVERY_FEES[$delivery], 2);

        try {
            $orderId = DB::transaction(function () use ($userId, $orderNumber, $total, $address, $payment, $lines) {
                $order = Order::create([
                    'user_id'          => $userId,
                    'order_number'     => $orderNumber,
                    'status'           => 'pending',
                    'total'            => $total,
                    'delivery_address' => $address,
                    'payment_method'   => $payment,
                    'payment_status'   => 'unpaid',
                ]);

                foreach ($lines as $line) {
                    OrderItem::create([
                        'order_id'   => $order->id,
                        'plant_id'   => $line['plant']->id,
                        'plant_name' => $line['plant']->name,
                        'price'      => $line['price'],
                        'quantity'   => $line['quantity'],
                    ]);
                }

                // the "Order Placed" notification is raised by OrderObserver

                return $order->id;
            });
        } catch (Throwable $e) {
            // the raw exception text (SQL and all) is for the log, not the customer
            Log::error('Order placement failed', ['user_id' => $userId, 'exception' => $e]);

            return response()->json([
                'success' => false,
                'message' => "We couldn't place your order. Please try again.",
            ], 500);
        }

        return response()->json([
            'success'  => true,
            'message'  => 'Order placed.',
            'order_id' => (int) $orderId,
            'total'    => $total,
        ]);
    }

    /**
     * Customers can only cancel their own order, and only while it's still
     * pending and unpaid. Every other status change belongs to the admin panel.
     */
    public function cancel(Request $request, int $order, OrderPayments $payments)
    {
        $found = $request->user()->orders()->find($order);

        if (! $found) {
            return response()->json(['success' => false, 'message' => 'Order not found.'], 404);
        }

        // close any open PayWay transaction first, so a saved QR code can't be paid afterwards
        if ($found->status === 'pending' && $found->payment_status !== 'paid') {
            try {
                $payments->settle($found);
            } catch (PayWayException $e) {
                Log::error('PayWay close failed while cancelling an order', ['order_id' => $found->id, 'error' => $e->getMessage()]);

                return response()->json([
                    'success' => false,
                    'message' => "We couldn't cancel the payment with ABA PayWay. Please try again.",
                ], 502);
            }
        }

        [$status, $message] = DB::transaction(function () use ($request, $order) {
            // locked so an admin confirming at the same moment can't be overwritten
            $found = $request->user()->orders()->lockForUpdate()->find($order);

            if (! $found) {
                return [404, 'Order not found.'];
            }

            // a retried request after a dropped connection shouldn't look like a failure
            if ($found->status === 'cancelled') {
                return [200, 'Order cancelled.'];
            }

            if ($found->payment_status === 'paid') {
                return [422, 'This order is already paid, so it can no longer be cancelled here. Please contact us.'];
            }

            if ($found->status !== 'pending') {
                return [422, 'This order is already being processed and can no longer be cancelled.'];
            }

            // saved through the model so OrderObserver raises the notification
            $found->status = 'cancelled';
            $found->save();

            return [200, 'Order cancelled.'];
        });

        return response()->json([
            'success' => $status === 200,
            'message' => $message,
        ], $status);
    }
}
