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

if (!isset($data["user_id"], $data["student_name"], $data["notification_type"])) {
    echo json_encode(["error" => "Missing required fields"]);
    exit;
}

$user_id = $conn->real_escape_string($data["user_id"]);
$student_name = $conn->real_escape_string($data["student_name"]);
$notification_type = $conn->real_escape_string($data["notification_type"]);
$appointment_id = isset($data["appointment_id"]) ? $conn->real_escape_string($data["appointment_id"]) : null;
$service_type = isset($data["service_type"]) ? $conn->real_escape_string($data["service_type"]) : null;
$date_requested = isset($data["date_requested"]) ? $conn->real_escape_string($data["date_requested"]) : null;
$time_requested = isset($data["time_requested"]) ? $conn->real_escape_string($data["time_requested"]) : null;
$message = isset($data["message"]) ? $conn->real_escape_string($data["message"]) : null;

$sql = "INSERT INTO wdt_notifications (user_id, student_name, notification_type, appointment_id, service_type, date_requested, time_requested, message) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssssisss", $user_id, $student_name, $notification_type, $appointment_id, $service_type, $date_requested, $time_requested, $message);

if ($stmt->execute()) {
    echo json_encode(["success" => "Notification created successfully", "notification_id" => $stmt->insert_id]);
} else {
    echo json_encode(["error" => "Failed to create notification", "details" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>