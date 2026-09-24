<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Plant;
use App\Models\Review;
use Illuminate\Http\Request;

/**
 * Customer reviews. Ratings only originate here — the admin panel can moderate
 * what customers wrote but never author or edit it.
 *
 * Like the rest of this API, the caller identifies itself with a `user_id`
 * rather than a token, matching the existing app. That's fine for a local
 * project but means the client is trusted; real auth would want tokens.
 */
class ReviewController extends Controller
{
    public function index(Request $request)
    {
        $plantId = (int) $request->query('plant_id', 0);
        $userId  = (int) $request->query('user_id', 0);

        $plant = Plant::find($plantId);

        if (! $plant) {
            return response()->json(['success' => false, 'message' => 'Plant not found.'], 404);
        }

        return $this->payload($plant, $userId);
    }

    public function store(Request $request)
    {
        $plantId = (int) $request->input('plant_id', 0);
        $userId  = (int) $request->input('user_id', 0);
        $rating  = (int) $request->input('rating', 0);
        $body    = trim((string) $request->input('body', ''));

        $plant = Plant::find($plantId);

        if (! $plant || $userId === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Sign in to leave a review.',
            ], 422);
        }

        if ($rating < 1 || $rating > 5) {
            return response()->json([
                'success' => false,
                'message' => 'Pick between 1 and 5 stars.',
            ], 422);
        }

        $review = Review::updateOrCreate(
            ['plant_id' => $plantId, 'user_id' => $userId],
            ['rating' => $rating, 'body' => $body === '' ? null : $body]
        );

        // If an admin had hidden this person's review, editing it brings it back
        // rather than leaving them silently shadow-banned.
        if ($review->isHidden()) {
            $review->forceFill(['hidden_at' => null])->save();
        }

        return $this->payload($plant->fresh(), $userId);
    }

    public function destroy(Request $request)
    {
        $plantId  = (int) $request->input('plant_id', 0);
        $userId   = (int) $request->input('user_id', 0);
        $reviewId = (int) $request->input('review_id', 0);

        $plant = Plant::find($plantId);

        if (! $plant) {
            return response()->json(['success' => false, 'message' => 'Plant not found.'], 404);
        }

        $review = Review::find($reviewId);

        // only the author may remove their own review
        if ($review && $review->plant_id === $plantId && $review->user_id === $userId) {
            $review->delete();
        }

        return $this->payload($plant->fresh(), $userId);
    }

    /**
     * Every endpoint returns this same shape so the client can replace its state
     * wholesale after any change instead of re-fetching the plant too.
     */
    private function payload(Plant $plant, int $userId)
    {
        $reviews = $plant->reviews()
            ->visible()
            ->with('user')
            ->latest()
            ->limit(100)
            ->get();

        $mine = $userId !== 0
            ? $plant->reviews()->where('user_id', $userId)->with('user')->first()
            : null;

        return response()->json([
            'success' => true,
            'summary' => [
                'rating'        => (float) $plant->rating,
                'reviews_count' => (int) $plant->counting,
                'distribution'  => $plant->ratingDistribution(),
                'has_rating'    => (int) $plant->counting > 0,
            ],
            'reviews'   => $reviews->map(fn (Review $r) => $this->reviewPayload($r, $userId))->values(),
            // Included even when hidden so the author still sees their own text.
            'my_review' => $mine ? $this->reviewPayload($mine, $userId) : null,
            'my_review_hidden' => $mine?->isHidden() ?? false,
            'can_review' => $userId !== 0,
        ]);
    }

    private function reviewPayload(Review $review, int $viewerId): array
    {
        $avatar = $review->user?->avatar;

        return [
            'id'          => (int) $review->id,
            'rating'      => (int) $review->rating,
            'body'        => $review->body,
            'author_name' => $review->user?->name ?? 'Someone',
            'author_avatar' => filled($avatar)
                ? url('uploads/avatars/'.rawurlencode($avatar))
                : '',
            'is_mine'     => $review->user_id === $viewerId,
            'created_at'  => optional($review->created_at)->format('Y-m-d H:i:s'),
            'updated_at'  => optional($review->updated_at)->format('Y-m-d H:i:s'),
        ];
    }
}
