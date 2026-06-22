<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query("SELECT * FROM plants ORDER BY id ASC");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // build image base URL from the incoming request so it works
    // regardless of which IP/host the client used to reach the server
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $imageBaseURL = "$scheme://{$_SERVER['HTTP_HOST']}/PP-Backend/uploads/plants/";

    $plants = array_map(function ($row) use ($imageBaseURL) {
        return [
            "id"            => (int)$row["id"],
            "image"         => $imageBaseURL . rawurlencode($row["image"]),
            "name"          => $row["name"],
            "type"          => $row["type"],
            "type_plant"    => $row["type_plant"],
            "price"         => (float)$row["price"],
            "description"   => $row["description"],
            "rating"        => (float)$row["rating"],
            "counting"      => (int)$row["counting"],
            "is_popular"    => (bool)$row["is_popular"],
            "discount_price" => $row["discount_price"] !== null ? (float)$row["discount_price"] : null,
        ];
    }, $rows);

    echo json_encode(["success" => true, "plants" => $plants]);
}
?>
