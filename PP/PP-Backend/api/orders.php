<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    $userId      = $data["user_id"] ?? 0;
    $orderNumber = $data["order_number"] ?? "";
    $total       = $data["total"] ?? 0;
    $address     = $data["delivery_address"] ?? "";
    $items       = $data["items"] ?? [];

    if (empty($userId) || empty($orderNumber) || empty($items)) {
        echo json_encode(["success" => false, "message" => "Missing required fields."]);
        exit();
    }

    try {
        $pdo->beginTransaction();

        $stmt = $pdo->prepare("
            INSERT INTO orders (user_id, order_number, status, total, delivery_address)
            VALUES (?, ?, 'pending', ?, ?)
        ");
        $stmt->execute([$userId, $orderNumber, $total, $address]);
        $orderId = $pdo->lastInsertId();

        $itemStmt = $pdo->prepare("
            INSERT INTO order_items (order_id, plant_id, plant_name, price, quantity)
            VALUES (?, ?, ?, ?, ?)
        ");
        foreach ($items as $item) {
            $itemStmt->execute([
                $orderId,
                $item["plant_id"],
                $item["plant_name"],
                $item["price"],
                $item["quantity"]
            ]);
        }

        // save notification
        $notifStmt = $pdo->prepare("
            INSERT INTO notifications (user_id, title, message, type)
            VALUES (?, 'Order Placed', ?, 'orderPlaced')
        ");
        $notifStmt->execute([$userId, "Your order #$orderNumber is pending confirmation."]);

        $pdo->commit();

        echo json_encode(["success" => true, "message" => "Order placed.", "order_id" => $orderId]);

    } catch (Exception $e) {
        $pdo->rollBack();
        echo json_encode(["success" => false, "message" => $e->getMessage()]);
    }

} elseif ($method === 'GET') {
    $userId = $_GET['user_id'] ?? 0;

    $stmt = $pdo->prepare("SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->execute([$userId]);
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($orders as &$order) {
        $itemStmt = $pdo->prepare("SELECT * FROM order_items WHERE order_id = ?");
        $itemStmt->execute([$order["id"]]);
        $order["items"] = $itemStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode(["success" => true, "orders" => $orders]);

} elseif ($method === 'PUT') {
    $data    = json_decode(file_get_contents("php://input"), true);
    $orderId = $data["order_id"] ?? 0;
    $status  = $data["status"] ?? "";
    $userId  = $data["user_id"] ?? 0;

    $allowed = ['pending','confirmed','preparing','inTransit','delivered','cancelled','rejected'];
    if (!in_array($status, $allowed)) {
        echo json_encode(["success" => false, "message" => "Invalid status."]);
        exit();
    }

    $stmt = $pdo->prepare("UPDATE orders SET status = ? WHERE id = ?");
    $stmt->execute([$status, $orderId]);

    // add notification for status change
    $messages = [
        'confirmed'  => ['title' => 'Order Confirmed',  'msg' => "Your order has been confirmed!", 'type' => 'orderConfirmed'],
        'cancelled'  => ['title' => 'Order Cancelled',  'msg' => "Your order has been cancelled.", 'type' => 'orderCancelled'],
        'rejected'   => ['title' => 'Order Rejected',   'msg' => "Sorry, your order was rejected.", 'type' => 'orderRejected'],
        'delivered'  => ['title' => 'Order Delivered',  'msg' => "Your order has been delivered!", 'type' => 'orderDelivered'],
    ];

    if (isset($messages[$status]) && $userId) {
        $n = $messages[$status];
        $notifStmt = $pdo->prepare("
            INSERT INTO notifications (user_id, title, message, type)
            VALUES (?, ?, ?, ?)
        ");
        $notifStmt->execute([$userId, $n['title'], $n['msg'], $n['type']]);
    }

    echo json_encode(["success" => true, "message" => "Order status updated."]);
}
?>