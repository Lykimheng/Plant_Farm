<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Review extends Model
{
    protected $fillable = ['plant_id', 'user_id', 'rating', 'body'];

    protected function casts(): array
    {
        return [
            'rating'    => 'integer',
            'hidden_at' => 'datetime',
        ];
    }

    /**
     * The plant's `rating` and `counting` columns are a cache of this table.
     * Recomputing on every write means they can't drift, whether the change came
     * from a customer, an admin hiding something, or a deletion.
     */
    protected static function booted(): void
    {
        $sync = function (Review $review) {
            Plant::find($review->plant_id)?->recalculateRating();
        };

        static::saved($sync);
        static::deleted($sync);
    }

    public function scopeVisible(Builder $query): Builder
    {
        return $query->whereNull('hidden_at');
    }

    public function isHidden(): bool
    {
        return $this->hidden_at !== null;
    }

    public function plant(): BelongsTo
    {
        return $this->belongsTo(Plant::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
