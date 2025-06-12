<?php
// Allow Cross-Origin Requests
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8'); // Ensure JSON response

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

// Enable error logging
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed", "details" => $conn->connect_error]);
    exit;
}

// Get JSON input
$data = json_decode(file_get_contents("php://input"), true);
error_log("Received JSON: " . json_encode($data));

// Ensure required fields exist
if (!isset($data["id"]) || !isset($data["action"])) {
    echo json_encode(["error" => "Missing required fields: id or action"]);
    exit;
}

$appointment_id = $conn->real_escape_string($data["id"]);
$action = strtolower($conn->real_escape_string($data["action"])); // Convert action to lowercase

// Determine new status
if ($action === "accept") {
    $new_status = "Accepted";
} elseif ($action === "decline") {
    $new_status = "Declined";
} else {
    echo json_encode(["error" => "Invalid action. Use 'accept' or 'decline'"]);
    exit;
}

// Check if appointment exists
$check_sql = "SELECT id FROM request_appointments WHERE id = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("i", $appointment_id);
$check_stmt->execute();
$check_stmt->store_result();

if ($check_stmt->num_rows === 0) {
    echo json_encode(["error" => "Appointment does not exist"]);
    $check_stmt->close();
    exit;
}
$check_stmt->close();

// Update the appointment status
$sql = "UPDATE request_appointments SET status = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $new_status, $appointment_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(["success" => "Appointment status updated to $new_status"]);
    } else {
        echo json_encode(["error" => "Appointment not found or already updated"]);
    }
} else {
    error_log("SQL Error: " . $stmt->error);
    echo json_encode(["error" => "Failed to update appointment", "details" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>