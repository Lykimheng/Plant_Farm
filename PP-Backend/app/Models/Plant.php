<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Plant extends Model
{
    protected $fillable = [
        'image', 'name', 'type', 'type_plant', 'price',
        'description', 'rating', 'counting', 'is_popular', 'discount_price',
    ];

    public $timestamps = false;

    protected function casts(): array
    {
        return [
            'price'          => 'float',
            'rating'         => 'float',
            'counting'       => 'integer',
            'is_popular'     => 'boolean',
            'discount_price' => 'float',
        ];
    }

    /** Full public URL for the stored image filename. */
    public function imageUrl(): string
    {
        if (blank($this->image)) {
            return '';
        }

        return url('uploads/plants/'.rawurlencode($this->image));
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Rewrites the cached `rating` / `counting` columns from visible reviews.
     * Only runs when a review changes, so plants nobody has reviewed keep the
     * ratings they were seeded with.
     */
    public function recalculateRating(): void
    {
        $stats = $this->reviews()
            ->visible()
            ->selectRaw('COUNT(*) as total, AVG(rating) as average')
            ->first();

        $total = (int) ($stats->total ?? 0);

        $this->forceFill([
            'counting' => $total,
            'rating'   => $total > 0 ? round((float) $stats->average, 1) : 0.0,
        ])->saveQuietly();
    }

    /** Counts per star, e.g. ["5" => 3, "4" => 1, ...] — for the breakdown bars. */
    public function ratingDistribution(): array
    {
        $counts = $this->reviews()
            ->visible()
            ->selectRaw('rating, COUNT(*) as total')
            ->groupBy('rating')
            ->pluck('total', 'rating');

        $distribution = [];
        foreach (range(1, 5) as $star) {
            $distribution[(string) $star] = (int) ($counts[$star] ?? 0);
        }

        return $distribution;
    }
}
