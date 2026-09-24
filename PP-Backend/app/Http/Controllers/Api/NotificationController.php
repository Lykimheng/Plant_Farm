<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $userId = (int) $request->query('user_id', 0);

        $notifications = AppNotification::where('user_id', $userId)
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
        $userId  = (int) $request->input('user_id', 0);
        $notifId = $request->input('notification_id');

        $query = AppNotification::where('user_id', $userId);

        if (filled($notifId)) {
            $query->where('id', (int) $notifId);
        }

        $query->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Marked as read.',
        ]);
    }

    public function destroy(Request $request)
    {
        $userId  = (int) $request->input('user_id', 0);
        $notifId = $request->input('notification_id');

        $query = AppNotification::where('user_id', $userId);

        if (filled($notifId)) {
            $query->where('id', (int) $notifId);
        }

        $query->delete();

        return response()->json([
            'success' => true,
            'message' => 'Deleted.',
        ]);
    }
}
