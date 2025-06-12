<?php
// Start output buffering
ob_start();

// Debug logging
error_log("SCRIPT STARTED - create_cancellation_request.php");
file_put_contents('debug.log', date('Y-m-d H:i:s') . " - Script started\n", FILE_APPEND);

// Set headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

// Handle OPTIONS request (CORS preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'php_errors.log');

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

try {
    $conn = new mysqli($servername, $username, $password, $database);
    
    if ($conn->connect_error) {
        throw new Exception("Database Connection Failed: " . $conn->connect_error);
    }

    // Get JSON input
    $json = file_get_contents('php://input');
    if ($json === false) {
        throw new Exception("Failed to read input data");
    }

    $data = json_decode($json, true);
    if ($data === null) {
        throw new Exception("Invalid JSON data");
    }

    // Log received data for debugging
    error_log("Received data: " . print_r($data, true));
    file_put_contents('received_data.log', print_r($data, true), FILE_APPEND);

    // Validate required fields (for cancellation)
    $required_fields = [
        "appointment_id" => "Appointment ID",
        "coach_id" => "Coach ID", 
        "student_name" => "Student Name",
        "original_date" => "Original Date",
        "original_time" => "Original Time",
        "reason" => "Reason"
    ];

    $missing_fields = [];
    foreach ($required_fields as $field => $name) {
        if (!isset($data[$field])) {
            $missing_fields[] = $name;
        }
    }

    if (!empty($missing_fields)) {
        throw new Exception("Missing required fields: " . implode(", ", $missing_fields));
    }

    // Verify the data exists in the database
    $verify_stmt = $conn->prepare("
        SELECT a.id, a.coach_id, a.student_name, a.date_requested, a.time_requested
        FROM appointments a
        WHERE a.id = ? AND a.coach_id = ? AND a.student_name = ?
        AND a.date_requested = ? AND a.time_requested = ?
    ");
    $verify_stmt->bind_param(
        "issss", 
        $data["appointment_id"],
        $data["coach_id"],
        $data["student_name"],
        $data["original_date"],
        $data["original_time"]
    );
    $verify_stmt->execute();
    $verify_result = $verify_stmt->get_result();

    if ($verify_result->num_rows === 0) {
        throw new Exception("No matching appointment found with the provided details");
    }

    // Sanitize input
    $appointment_id = $conn->real_escape_string($data["appointment_id"]);
    $coach_id = $conn->real_escape_string($data["coach_id"]);
    $student_name = $conn->real_escape_string($data["student_name"]);
    $original_date = $conn->real_escape_string($data["original_date"]);
    $original_time = $conn->real_escape_string($data["original_time"]);
    $reason = $conn->real_escape_string($data["reason"]);

    // Start transaction
    $conn->begin_transaction();

    try {
        // 1. Insert into cancellation table with status 'Pending'
        $stmt = $conn->prepare("INSERT INTO coach_cancellation_requests 
                              (appointment_id, coach_id, student_name, original_date, original_time, reason, status) 
                              VALUES (?, ?, ?, ?, ?, ?, 'Pending')");
        
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("iissss", $appointment_id, $coach_id, $student_name, $original_date, $original_time, $reason);
        $stmt->execute();

        if ($stmt->affected_rows === 0) {
            throw new Exception("Failed to create cancellation request");
        }

        $new_id = $stmt->insert_id;
        
        // 2. Update the request_appointments status to 'Cancelled' (this will trigger the appointment update)
        $update_request_stmt = $conn->prepare("UPDATE request_appointments SET status = 'Cancelled' WHERE appointment_id = ?");
        if (!$update_request_stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $update_request_stmt->bind_param("i", $appointment_id);
        $update_request_stmt->execute();
        
        if ($update_request_stmt->affected_rows === 0) {
            throw new Exception("Failed to update request_appointments status");
        }

        // Commit transaction
        $conn->commit();

        // Success response
        ob_end_clean();
        echo json_encode([
            "success" => true,
            "message" => "Cancellation request submitted successfully",
            "id" => $new_id
        ]);
        exit;

    } catch (Exception $e) {
        // Rollback transaction on error
        $conn->rollback();
        throw $e;
    }

} catch (Exception $e) {
    // Error response
    ob_end_clean();
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
    exit;
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}