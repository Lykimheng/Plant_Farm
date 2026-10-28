<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = $request->user()->appNotifications()
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (AppNotification $n) => [
                'id'         => (int) $n->id,
                'user_id'    => (int) $n->user_id,
                'title'      => $n->title,
                'message'    => $n->message,
                'type'       => $n->type,
                'is_read'    => $n->is_read ? 1 : 0,
                'created_at' => $n->getRawOriginal('created_at'),
            ]);

        return response()->json([
            'success'       => true,
            'notifications' => $notifications,
        ]);
    }

    public function markRead(Request $request)
    {
        $this->scope($request)->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Marked as read.',
        ]);
    }

    public function destroy(Request $request)
    {
        $this->scope($request)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Deleted.',
        ]);
    }

    /** The one notification named by `notification_id`, or all of the caller's. */
    private function scope(Request $request)
    {
        $query   = $request->user()->appNotifications();
        $notifId = $request->input('notification_id');

        if (filled($notifId)) {
            $query->whereKey((int) $notifId);

            // someone else's id is a 404, not a silent no-op
            abort_unless($query->exists(), 404);
        }

        return $query;
    }
}
