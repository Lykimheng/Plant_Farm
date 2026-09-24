<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Named AppNotification to avoid colliding with Laravel's own notification
 * system, but backed by the app's existing `notifications` table.
 */
class AppNotification extends Model
{
    protected $table = 'notifications';

    protected $fillable = [
        'user_id', 'title', 'message', 'type', 'is_read',
    ];

    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'user_id' => 'integer',
            'is_read' => 'boolean',
        ];
    }
}
