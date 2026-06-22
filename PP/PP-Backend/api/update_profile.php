<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'PUT') {
    $data   = json_decode(file_get_contents("php://input"), true);
    $userId = $data["user_id"] ?? 0;
    $name   = trim($data["name"] ?? "");

    if (empty($userId) || empty($name)) {
        echo json_encode(["success" => false, "message" => "Name is required."]);
        exit();
    }

    $stmt = $pdo->prepare("UPDATE users SET name = ? WHERE id = ?");
    $stmt->execute([$name, $userId]);

    echo json_encode(["success" => true, "message" => "Profile updated.", "name" => $name]);
}
?>
