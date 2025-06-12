<?php
// Start output buffering
ob_start();

// Add debug logging
error_log("SCRIPT STARTED - accept_appointment.php");
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
    if (!isset($data["id"]) || !isset($data["action"])) {
        throw new Exception("Missing required fields: id or action");
    }

    $appointment_id = $conn->real_escape_string($data["id"]);
    $action = strtolower($conn->real_escape_string($data["action"]));

    // Validate action
    if (!in_array($action, ['accept', 'decline'])) {
        throw new Exception("Invalid action. Use 'accept' or 'decline'");
    }

    $new_status = $action === "accept" ? "Accepted" : "Declined";

    // Begin transaction
    $conn->begin_transaction();

    try {
        // 1. Update request_appointments
        $stmt1 = $conn->prepare("UPDATE request_appointments SET status = ? WHERE id = ?");
        if (!$stmt1) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt1->bind_param("si", $new_status, $appointment_id);
        $stmt1->execute();
        
        if ($stmt1->affected_rows === 0) {
            throw new Exception("Appointment not found or already updated");
        }

        // 2. Update appointments
        $stmt2 = $conn->prepare("UPDATE appointments a 
                                JOIN request_appointments r ON a.id = r.appointment_id
                                SET a.status = ? 
                                WHERE r.id = ?");
        if (!$stmt2) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt2->bind_param("si", $new_status, $appointment_id);
        $stmt2->execute();

        $conn->commit();
        
        // Clear any output buffer and send success response
        ob_end_clean();
        echo json_encode(["success" => true, "message" => "Appointment status updated to $new_status"]);
        exit;
        
    } catch (Exception $e) {
        $conn->rollback();
        throw $e;
    }

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