<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * One attempt to pay an order through ABA PayWay.
 *
 * Status: pending → approved | declined | cancelled | expired | refunded |
 * failed, as reported by PayWay's check-transaction API.
 */
class Payment extends Model
{
    protected $fillable = [
        'order_id', 'tran_id', 'method', 'amount', 'currency', 'status',
        'apv', 'deeplink', 'qr_string', 'expires_at', 'paid_at',
    ];

    protected function casts(): array
    {
        return [
            'order_id'   => 'integer',
            'amount'     => 'float',
            'expires_at' => 'datetime',
            'paid_at'    => 'datetime',
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }
}
