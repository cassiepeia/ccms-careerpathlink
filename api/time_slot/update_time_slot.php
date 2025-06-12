<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set headers
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Methods, Access-Control-Allow-Origin");

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed", "details" => $conn->connect_error]));
}

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Ensure request method is PUT
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    die(json_encode(["error" => "Invalid request method. Only PUT is allowed."]));
}

// Read and decode input data
$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

// Debugging: Log received data
if (!$data) {
    die(json_encode(["error" => "Invalid JSON received", "received" => $rawData]));
}

// Check required field 'id'
if (!isset($data['id']) || empty($data['id'])) {
    die(json_encode(["error" => "Missing required field: id"]));
}

// Ensure only allowed fields are updated
$fieldsToUpdate = [];
if (isset($data['date_slot'])) $fieldsToUpdate[] = "date_slot = '" . $conn->real_escape_string($data['date_slot']) . "'";
if (isset($data['day'])) $fieldsToUpdate[] = "day = '" . $conn->real_escape_string($data['day']) . "'";
if (isset($data['start_time'])) $fieldsToUpdate[] = "start_time = '" . $conn->real_escape_string($data['start_time']) . "'";
if (isset($data['end_time'])) $fieldsToUpdate[] = "end_time = '" . $conn->real_escape_string($data['end_time']) . "'";

// Ensure we are updating at least one field
if (empty($fieldsToUpdate)) {
    die(json_encode(["error" => "No fields provided for update"]));
}

// Construct update query
$sql = "UPDATE time_slots SET " . implode(", ", $fieldsToUpdate) . " WHERE id = " . $conn->real_escape_string($data['id']);

if ($conn->query($sql) === TRUE) {
    echo json_encode(["message" => "Time slot updated successfully"]);
} else {
    echo json_encode(["error" => "Failed to update time slot", "sql_error" => $conn->error]);
}

$conn->close();
