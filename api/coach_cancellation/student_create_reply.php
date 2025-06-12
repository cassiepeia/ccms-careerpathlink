<?php
// Start output buffering
ob_start();

// Add debug logging
error_log("SCRIPT STARTED - update_student_reply.php");
file_put_contents('debug.log', date('Y-m-d H:i:s') . " - Script started\n", FILE_APPEND);

// Set headers first
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

// Handle OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

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

    // Only accept POST requests
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception("Only POST method is accepted");
    }

    // Get and validate input data
    $json = file_get_contents('php://input');
    if ($json === false) {
        throw new Exception("Failed to read input data");
    }

    $data = json_decode($json, true);
    if ($data === null) {
        throw new Exception("Invalid JSON data");
    }

    // Validate required fields
    $required_fields = ['id', 'student_reply'];
    foreach ($required_fields as $field) {
        if (!isset($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
        if (empty(trim($data[$field]))) {
            throw new Exception("Field cannot be empty: $field");
        }
    }

    // Prepare data (status is explicitly excluded from student updates)
    $id = $conn->real_escape_string($data['id']);
    $student_reply = $conn->real_escape_string($data['student_reply']);

    // Verify the request exists and is in a state that can receive student replies
    $verify_query = "SELECT status FROM coach_cancellation_requests 
                    WHERE id = ? AND student_reply IS NULL";
    $verify_stmt = $conn->prepare($verify_query);
    $verify_stmt->bind_param("i", $id);
    $verify_stmt->execute();
    $verify_result = $verify_stmt->get_result();
    
    if ($verify_result->num_rows === 0) {
        throw new Exception("Request not found or already has a student reply");
    }

    // Update only student_reply and reply_date (status remains unchanged)
    $query = "UPDATE coach_cancellation_requests SET 
              student_reply = ?,
              reply_date = NOW()
              WHERE id = ?";
    
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $stmt->bind_param("si", $student_reply, $id);
    $stmt->execute();
    
    if ($stmt->affected_rows === 0) {
        throw new Exception("No changes made to the request");
    }

    // Get the updated record to return
    $select_query = "SELECT * FROM coach_cancellation_requests WHERE id = ?";
    $select_stmt = $conn->prepare($select_query);
    $select_stmt->bind_param("i", $id);
    $select_stmt->execute();
    $result = $select_stmt->get_result();
    $updated_request = $result->fetch_assoc();

    // Clear any output buffer and send success response
    ob_end_clean();
    echo json_encode([
        "success" => true,
        "message" => "Student reply submitted successfully",
        "data" => $updated_request
    ]);
    exit;
    
} catch (Exception $e) {
    // Clear output buffer and send error
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