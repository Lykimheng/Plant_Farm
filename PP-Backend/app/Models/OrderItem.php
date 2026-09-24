<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    protected $fillable = [
        'order_id', 'plant_id', 'plant_name', 'price', 'quantity',
    ];

    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'plant_id' => 'integer',
            'price'    => 'float',
            'quantity' => 'integer',
        ];
    }

    public function plant()
    {
        return $this->belongsTo(Plant::class);
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
