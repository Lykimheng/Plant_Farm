<?php
require_once 'config.php';

// Get POST body
$data = json_decode(file_get_contents("php://input"), true);

$name     = trim($data["name"] ?? "");
$email    = trim($data["email"] ?? "");
$password = trim($data["password"] ?? "");
$location = trim($data["location"] ?? "");

// Validate inputs
if (empty($name) || empty($email) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Name, email and password are required."
    ]);
    exit();
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid email format."
    ]);
    exit();
}

// Check if email already exists
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->rowCount() > 0) {
    echo json_encode([
        "success" => false,
        "message" => "Email already registered."
    ]);
    exit();
}

// Hash password and insert
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);
$stmt = $pdo->prepare("
    INSERT INTO users (name, email, password, location, created_at)
    VALUES (?, ?, ?, ?, NOW())
");
$stmt->execute([$name, $email, $hashedPassword, $location]);
$userId = $pdo->lastInsertId();

echo json_encode([
    "success"  => true,
    "message"  => "Registration successful.",
    "user" => [
        "id"       => (int)$userId,
        "name"     => $name,
        "email"    => $email,
        "location" => $location,
        "avatar"   => ""
    ]
]);
?>