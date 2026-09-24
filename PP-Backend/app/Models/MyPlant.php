<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MyPlant extends Model
{
    protected $table = 'my_plants';

    protected $fillable = [
        'user_id', 'image', 'name', 'species',
        'care_level', 'next_watering', 'sunlight',
    ];

    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'user_id'    => 'integer',
            'added_date' => 'datetime',
        ];
    }
}
