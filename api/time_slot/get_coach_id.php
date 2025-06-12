<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

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

// Get user_id from query parameters
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if (!$user_id) {
    echo json_encode(["error" => "user_id parameter is required"]);
    exit;
}

// Fetch the coach_id based on the user_id
$sql = "SELECT id FROM coaches WHERE user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode(["coach_id" => $row['id']]);
} else {
    echo json_encode(["coach_id" => null]);
}

$stmt->close();
$conn->close();
?>