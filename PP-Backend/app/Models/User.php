<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

/**
 * Note: the Notifiable trait is intentionally NOT used. This app has its own
 * `notifications` table with a custom shape, and Notifiable's morphMany would
 * collide with it.
 */
class User extends Authenticatable
{
    protected $fillable = [
        'name',
        'email',
        'password',
        'location',
        'avatar',
        'is_admin',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    // the original schema has created_at only, no updated_at
    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_admin' => 'boolean',
        ];
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function myPlants()
    {
        return $this->hasMany(MyPlant::class);
    }

    public function appNotifications()
    {
        return $this->hasMany(AppNotification::class);
    }

    /** Gate for the Filament admin panel. */
    public function canAccessPanel(\Filament\Panel $panel): bool
    {
        return (bool) $this->is_admin;
    }
}
