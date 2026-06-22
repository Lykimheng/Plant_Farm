<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $data       = json_decode(file_get_contents("php://input"), true);
    $userId     = $data["user_id"] ?? 0;
    $imageBase64 = $data["image_base64"] ?? "";

    if (empty($userId) || empty($imageBase64)) {
        echo json_encode(["success" => false, "message" => "Missing user_id or image."]);
        exit();
    }

    $imageData = base64_decode($imageBase64);
    if ($imageData === false) {
        echo json_encode(["success" => false, "message" => "Invalid image data."]);
        exit();
    }

    $filename = "user{$userId}_" . time() . ".jpg";
    $filePath = __DIR__ . "/../uploads/avatars/" . $filename;

    if (file_put_contents($filePath, $imageData) === false) {
        echo json_encode(["success" => false, "message" => "Failed to save image."]);
        exit();
    }

    $stmt = $pdo->prepare("UPDATE users SET avatar = ? WHERE id = ?");
    $stmt->execute([$filename, $userId]);

    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $avatarUrl = "$scheme://{$_SERVER['HTTP_HOST']}/PP-Backend/uploads/avatars/$filename";

    echo json_encode(["success" => true, "message" => "Avatar updated.", "avatar_url" => $avatarUrl]);
}
?>
