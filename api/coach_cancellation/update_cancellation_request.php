<?php
// Start output buffering
ob_start();

// Add debug logging
error_log("SCRIPT STARTED - update_cancellation_request.php");
file_put_contents('debug.log', date('Y-m-d H:i:s') . " - Script started\n", FILE_APPEND);

// Set headers first
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS');
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

    // Get input data
    $json = file_get_contents('php://input');
    if ($json === false) {
        throw new Exception("Failed to read input data");
    }

    $data = json_decode($json, true);
    if ($data === null) {
        throw new Exception("Invalid JSON data");
    }

    // Validate required fields
    if (!isset($data["id"])) {
        throw new Exception("Missing required field: id");
    }

    $id = $conn->real_escape_string($data["id"]);
    $updates = [];
    $params = [];
    $types = "";

    // Check which fields are being updated
    if (isset($data["student_reply"])) {
        $updates[] = "student_reply = ?";
        $params[] = $conn->real_escape_string($data["student_reply"]);
        $types .= "s";
        
        // Set reply_date to current timestamp if student_reply is being updated
        $updates[] = "reply_date = NOW()";
    }

    if (isset($data["status"])) {
        if (!in_array($data["status"], ['Pending', 'Accepted', 'Declined'])) {
            throw new Exception("Invalid status value");
        }
        $updates[] = "status = ?";
        $params[] = $conn->real_escape_string($data["status"]);
        $types .= "s";
    }

    if (empty($updates)) {
        throw new Exception("No valid fields to update");
    }

    // Add id to params
    $params[] = $id;
    $types .= "i";

    // Build the query
    $query = "UPDATE coach_cancellation_requests SET " . implode(", ", $updates) . " WHERE id = ?";
    
    $stmt = $conn->prepare($query);
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    
    $stmt->bind_param($types, ...$params);
    $stmt->execute();
    
    if ($stmt->affected_rows === 0) {
        throw new Exception("No changes made or request not found");
    }

    // Clear any output buffer and send success response
    ob_end_clean();
    echo json_encode(["success" => true, "message" => "Cancellation request updated successfully"]);
    exit;
    
} catch (Exception $e) {
    // Clear output buffer and send error
    ob_end_clean();
    http_response_code(400);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}