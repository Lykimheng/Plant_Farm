<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Plant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Throwable;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $userId = (int) $request->query('user_id', 0);

        $orders = Order::with('items')
            ->where('user_id', $userId)
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
        $userId      = (int) $request->input('user_id', 0);
        $orderNumber = $this->stringInput($request, 'order_number');
        $total       = (float) $request->input('total', 0);
        $address     = $this->stringInput($request, 'delivery_address');
        $items       = $request->input('items', []);

        if ($userId === 0 || $orderNumber === '' || empty($items)) {
            return response()->json([
                'success' => false,
                'message' => 'Missing required fields.',
            ]);
        }

        try {
            $orderId = DB::transaction(function () use ($userId, $orderNumber, $total, $address, $items) {
                $order = Order::create([
                    'user_id'          => $userId,
                    'order_number'     => $orderNumber,
                    'status'           => 'pending',
                    'total'            => $total,
                    'delivery_address' => $address,
                ]);

                foreach ($items as $item) {
                    OrderItem::create([
                        'order_id'   => $order->id,
                        'plant_id'   => (int) ($item['plant_id'] ?? 0),
                        'plant_name' => $item['plant_name'] ?? '',
                        'price'      => (float) ($item['price'] ?? 0),
                        'quantity'   => (int) ($item['quantity'] ?? 0),
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
            ]);
        }

        return response()->json([
            'success'  => true,
            'message'  => 'Order placed.',
            'order_id' => (int) $orderId,
        ]);
    }

    public function updateStatus(Request $request)
    {
        $orderId = (int) $request->input('order_id', 0);
        $status  = $this->stringInput($request, 'status');

        $allowed = ['pending', 'confirmed', 'preparing', 'inTransit', 'delivered', 'cancelled', 'rejected'];

        if (! in_array($status, $allowed, true)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid status.',
            ]);
        }

        // save through the model (not a mass update) so OrderObserver fires and
        // raises the customer notification
        $order = Order::find($orderId);

        if ($order) {
            $order->status = $status;
            $order->save();
        }

        return response()->json([
            'success' => true,
            'message' => 'Order status updated.',
        ]);
    }
}
