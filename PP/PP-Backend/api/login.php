<?php
require_once 'config.php';

$data     = json_decode(file_get_contents("php://input"), true);
$email    = trim($data["email"] ?? "");
$password = trim($data["password"] ?? "");

// Validate inputs
if (empty($email) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Email and password are required."
    ]);
    exit();
}

// Find user
$stmt = $pdo->prepare("SELECT * FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || !password_verify($password, $user["password"])) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid email or password."
    ]);
    exit();
}

$scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$avatarUrl = !empty($user["avatar"])
    ? "$scheme://{$_SERVER['HTTP_HOST']}/PP-Backend/uploads/avatars/{$user['avatar']}"
    : "";

echo json_encode([
    "success" => true,
    "message" => "Login successful.",
    "user" => [
        "id"       => $user["id"],
        "name"     => $user["name"],
        "email"    => $user["email"],
        "location" => $user["location"],
        "avatar"   => $avatarUrl
    ]
]);
?>