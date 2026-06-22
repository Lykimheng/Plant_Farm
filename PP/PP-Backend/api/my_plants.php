<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $userId = $_GET['user_id'] ?? 0;

    $stmt = $pdo->prepare("SELECT * FROM my_plants WHERE user_id = ? ORDER BY added_date DESC");
    $stmt->execute([$userId]);
    $plants = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["success" => true, "plants" => $plants]);

} elseif ($method === 'POST') {
    $data        = json_decode(file_get_contents("php://input"), true);
    $userId      = $data["user_id"] ?? 0;
    $image       = $data["image"] ?? "";
    $name        = $data["name"] ?? "";
    $species     = $data["species"] ?? "";
    $careLevel   = $data["care_level"] ?? "easy";
    $nextWatering = $data["next_watering"] ?? "";
    $sunlight    = $data["sunlight"] ?? "";

    if (empty($userId) || empty($name)) {
        echo json_encode(["success" => false, "message" => "Missing required fields."]);
        exit();
    }

    $stmt = $pdo->prepare("
        INSERT INTO my_plants (user_id, image, name, species, care_level, next_watering, sunlight)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->execute([$userId, $image, $name, $species, $careLevel, $nextWatering, $sunlight]);
    $plantId = $pdo->lastInsertId();

    echo json_encode([
        "success" => true,
        "message" => "Plant added.",
        "plant_id" => $plantId
    ]);

} elseif ($method === 'DELETE') {
    $data    = json_decode(file_get_contents("php://input"), true);
    $plantId = $data["plant_id"] ?? 0;
    $userId  = $data["user_id"] ?? 0;

    $stmt = $pdo->prepare("DELETE FROM my_plants WHERE id = ? AND user_id = ?");
    $stmt->execute([$plantId, $userId]);

    echo json_encode(["success" => true, "message" => "Plant removed."]);
}
?>