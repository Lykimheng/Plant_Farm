<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId = $_GET['user_id'] ?? 0;

    $stmt = $pdo->prepare("
        SELECT * FROM notifications
        WHERE user_id = ?
        ORDER BY created_at DESC
    ");
    $stmt->execute([$userId]);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "notifications" => $notifications]);

} elseif ($method === 'PUT') {
    // mark as read
    $data   = json_decode(file_get_contents("php://input"), true);
    $userId = $data["user_id"] ?? 0;
    $notifId = $data["notification_id"] ?? null;

    if ($notifId) {
        // mark single
        $stmt = $pdo->prepare("UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?");
        $stmt->execute([$notifId, $userId]);
    } else {
        // mark all
        $stmt = $pdo->prepare("UPDATE notifications SET is_read = TRUE WHERE user_id = ?");
        $stmt->execute([$userId]);
    }

    echo json_encode(["success" => true, "message" => "Marked as read."]);

} elseif ($method === 'DELETE') {
    $data    = json_decode(file_get_contents("php://input"), true);
    $userId  = $data["user_id"] ?? 0;
    $notifId = $data["notification_id"] ?? null;

    if ($notifId) {
        $stmt = $pdo->prepare("DELETE FROM notifications WHERE id = ? AND user_id = ?");
        $stmt->execute([$notifId, $userId]);
    } else {
        $stmt = $pdo->prepare("DELETE FROM notifications WHERE user_id = ?");
        $stmt->execute([$userId]);
    }

    echo json_encode(["success" => true, "message" => "Deleted."]);
}
?>