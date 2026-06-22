<?php
require_once 'config.php';

$data = json_decode(file_get_contents("php://input"), true);
$email = trim($data["email"] ?? "");
$newPassword = trim($data["newPassword"] ?? "");

// Validate inputs
if (empty($email) || empty($newPassword)) {
    echo json_encode([
        "success" => false,
        "message" => "Email and new password are required."
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

// Check if email exists
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->rowCount() == 0) {
    echo json_encode([
        "success" => false,
        "message" => "No account found with this email."
    ]);
    exit();
}

// Update password
$hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);
$stmt = $pdo->prepare("UPDATE users SET password = ? WHERE email = ?");
$stmt->execute([$hashedPassword, $email]);

echo json_encode([
    "success" => true,
    "message" => "Password updated successfully."
]);
?>