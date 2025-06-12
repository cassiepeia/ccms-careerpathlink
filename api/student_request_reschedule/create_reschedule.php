<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Methods, Authorization");

// Function to return a JSON error response
function jsonError($message, $statusCode = 400) {
    http_response_code($statusCode);
    echo json_encode(["error" => $message]);
    exit;
}

// Log function for debugging
function logDebug($message) {
    file_put_contents('debug.log', date('Y-m-d H:i:s') . " - " . $message . "\n", FILE_APPEND);
}

// ✅ Handle CORS Preflight Requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

logDebug("Script started.");

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

// Check database connection
if ($conn->connect_error) {
    logDebug("Database Connection Failed: " . $conn->connect_error);
    jsonError("Database Connection Failed: " . $conn->connect_error, 500);
}

$conn->set_charset("utf8");

// ✅ Ensure POST Request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    logDebug("Invalid request method. Use POST.");
    jsonError("Invalid request method. Use POST.", 405);
}

logDebug("Request method is POST.");

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    logDebug("Invalid JSON input: " . file_get_contents('php://input'));
    jsonError("Invalid JSON input.");
}

logDebug("JSON input received: " . print_r($input, true));

// Validate required fields
$requiredFields = ["appointment_id", "student_name", "date_request", "time_request", "message"];
foreach ($requiredFields as $field) {
    if (!isset($input[$field])) {
        logDebug("Missing required field: " . $field);
        jsonError(ucfirst(str_replace("_", " ", $field)) . " is required.");
    }
}

logDebug("All required fields are present.");

// Extract and sanitize input
$appointment_id = $conn->real_escape_string($input['appointment_id']);
$student_name = $conn->real_escape_string($input['student_name']);
$date_request = $conn->real_escape_string($input['date_request']);
$time_request = $conn->real_escape_string($input['time_request']);
$message = $conn->real_escape_string($input['message']);

// Get coach_id from the appointment
$get_coach_query = $conn->prepare("SELECT coach_id FROM appointments WHERE id = ?");
$get_coach_query->bind_param("i", $appointment_id);
$get_coach_query->execute();
$coach_result = $get_coach_query->get_result();

if ($coach_result->num_rows === 0) {
    logDebug("Appointment not found: " . $appointment_id);
    jsonError("Appointment not found.", 404);
}

$coach_data = $coach_result->fetch_assoc();
$coach_id = $coach_data['coach_id'];

// Validate date_request in sessions table
$check_date_query = $conn->prepare("SELECT * FROM sessions WHERE session_date = ?");
$check_date_query->bind_param("s", $date_request);
$check_date_query->execute();
$check_date_result = $check_date_query->get_result();

if ($check_date_result->num_rows === 0) {
    logDebug("Date not found in sessions table: " . $date_request);
    jsonError("Invalid date. The requested date does not exist in the sessions table.");
}

// Validate time_request in sessions table
$check_time_query = $conn->prepare("SELECT * FROM sessions WHERE session_time = ?");
$check_time_query->bind_param("s", $time_request);
$check_time_query->execute();
$check_time_result = $check_time_query->get_result();

if ($check_time_result->num_rows === 0) {
    logDebug("Time not found in sessions table: " . $time_request);
    jsonError("Invalid time. The requested time does not exist in the sessions table.");
}

logDebug("Date and time validated.");

// ✅ Insert reschedule request into reschedule_requests table with coach_id
$insert_query = $conn->prepare("INSERT INTO reschedule_requests (appointment_id, student_name, coach_id, date_request, time_request, message, status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')");
if (!$insert_query) {
    logDebug("Failed to prepare insert query: " . $conn->error);
    jsonError("Failed to prepare insert query: " . $conn->error, 500);
}

$insert_query->bind_param("isssss", $appointment_id, $student_name, $coach_id, $date_request, $time_request, $message);

if ($insert_query->execute()) {
    logDebug("Reschedule request submitted successfully.");
    http_response_code(200);
    echo json_encode(["success" => "Reschedule request submitted successfully"]);
} else {
    logDebug("Failed to submit request: " . $insert_query->error);
    jsonError("Failed to submit request: " . $insert_query->error, 500);
}

$conn->close();
?>