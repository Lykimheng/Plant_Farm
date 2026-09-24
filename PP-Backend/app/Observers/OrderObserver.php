<?php

namespace App\Observers;

use App\Models\AppNotification;
use App\Models\Order;

/**
 * Single source of truth for customer order notifications, so they fire the
 * same way whether an order changes via the mobile API or the admin panel.
 */
class OrderObserver
{
    /** Status transitions that notify the customer. */
    private const STATUS_MESSAGES = [
        'confirmed' => ['Order Confirmed', 'Your order has been confirmed!', 'orderConfirmed'],
        'cancelled' => ['Order Cancelled', 'Your order has been cancelled.', 'orderCancelled'],
        'rejected'  => ['Order Rejected', 'Sorry, your order was rejected.', 'orderRejected'],
        'delivered' => ['Order Delivered', 'Your order has been delivered!', 'orderDelivered'],
    ];

    public function created(Order $order): void
    {
        AppNotification::create([
            'user_id' => $order->user_id,
            'title'   => 'Order Placed',
            'message' => "Your order #{$order->order_number} is pending confirmation.",
            'type'    => 'orderPlaced',
        ]);
    }

    public function updated(Order $order): void
    {
        if (! $order->wasChanged('status')) {
            return;
        }

        $status = $order->status;

        if (! isset(self::STATUS_MESSAGES[$status])) {
            return;
        }

        [$title, $message, $type] = self::STATUS_MESSAGES[$status];

        // the order owns the user id — never trust a client-supplied one
        AppNotification::create([
            'user_id' => $order->user_id,
            'title'   => $title,
            'message' => $message,
            'type'    => $type,
        ]);
    }
}
