<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: DELETE");

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
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Get raw JSON input
    $input = json_decode(file_get_contents('php://input'), true);

    // Validate required fields
    if (!isset($input['id']) || empty($input['id'])) {
        echo json_encode(["error" => "Reschedule Request ID is required"]);
        exit;
    }

    // Sanitize input data
    $id = $conn->real_escape_string($input['id']);

    // Delete reschedule request from the database
    $delete_query = "DELETE FROM reschedule_requests WHERE id = '$id'";

    if ($conn->query($delete_query) === TRUE) {
        echo json_encode(["success" => "Reschedule request deleted successfully"]);
    } else {
        echo json_encode(["error" => "Failed to delete reschedule request: " . $conn->error]);
    }
} else {
    echo json_encode(["error" => "Invalid request method. Use DELETE."]);
}

$conn->close();
?>