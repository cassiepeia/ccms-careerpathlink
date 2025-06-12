<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT");

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

// Connect to MySQL
$conn = new mysqli($servername, $username, $password, $database);

// Check for connection error
if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed: " . $conn->connect_error]);
    exit;
}

// Set character set to UTF-8
$conn->set_charset("utf8");

// Validate input data
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    // Get raw JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    if (!isset($input['id']) || empty($input['id'])) {
        echo json_encode(["error" => "Reschedule Request ID is required"]);
        exit;
    }
    if (!isset($input['message']) || empty($input['message'])) {
        echo json_encode(["error" => "Message is required"]);
        exit;
    }

    // Sanitize input data
    $id = $conn->real_escape_string($input['id']);
    $message = $conn->real_escape_string($input['message']);

    // Update reschedule request in the database
    $update_query = "UPDATE reschedule_requests SET message = '$message' WHERE id = '$id'";

    if ($conn->query($update_query) === TRUE) {
        echo json_encode(["success" => "Reschedule request updated successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update reschedule request: " . $conn->error]);
    }
} else {
    echo json_encode(["error" => "Invalid request method. Use PUT."]);
}

$conn->close();
?>