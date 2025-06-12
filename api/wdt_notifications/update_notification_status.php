<?php
// 1. CORS Headers (MUST come first)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// 2. Timezone Setting
date_default_timezone_set('UTC');

// 3. Then your other headers
header('Content-Type: application/json');

// 4. Error reporting (optional but recommended)
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

// 5. Then your database connection and logic
$conn = new mysqli("localhost", "root", "", "final_careercoaching");

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed", "details" => $conn->connect_error]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data["id"], $data["status"])) {
    echo json_encode(["error" => "Missing required fields"]);
    exit;
}

$id = $conn->real_escape_string($data["id"]);
$status = $conn->real_escape_string($data["status"]);

$sql = "UPDATE wdt_notifications SET status = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $status, $id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => "Notification status updated successfully"]);
    } else {
        echo json_encode(["error" => "No notification found with the given ID"]);
    }
} else {
    echo json_encode(["error" => "Failed to update notification status", "details" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>