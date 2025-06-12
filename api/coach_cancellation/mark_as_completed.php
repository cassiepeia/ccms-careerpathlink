<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

try {
    $conn = new mysqli($servername, $username, $password, $database);
    
    if ($conn->connect_error) {
        throw new Exception("Database Connection Failed: " . $conn->connect_error);
    }

    $json = file_get_contents('php://input');
    if ($json === false) {
        throw new Exception("Failed to read input data");
    }

    $data = json_decode($json, true);
    if ($data === null) {
        throw new Exception("Invalid JSON data");
    }

    $required_fields = ["appointment_id", "coach_id", "student_name", "original_date", "original_time"];
    foreach ($required_fields as $field) {
        if (!isset($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }

    $appointment_id = $conn->real_escape_string($data["appointment_id"]);
    $coach_id = $conn->real_escape_string($data["coach_id"]);
    $student_name = $conn->real_escape_string($data["student_name"]);
    $original_date = $conn->real_escape_string($data["original_date"]);
    $original_time = $conn->real_escape_string($data["original_time"]);

    $conn->begin_transaction();

    try {
        // 1. Update request_appointments status to 'Completed' first
        $update_request_stmt = $conn->prepare("UPDATE request_appointments SET status = 'Completed' WHERE appointment_id = ?");
        if (!$update_request_stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $update_request_stmt->bind_param("i", $appointment_id);
        $update_request_stmt->execute();
        
        if ($update_request_stmt->affected_rows === 0) {
            throw new Exception("No appointment found with ID: $appointment_id");
        }

        // 2. The trigger will automatically update the appointments table
        
        $conn->commit();

        echo json_encode([
            "success" => true,
            "message" => "Appointment marked as completed successfully"
        ]);

    } catch (Exception $e) {
        $conn->rollback();
        throw $e;
    }

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}