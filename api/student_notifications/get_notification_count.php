<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// Get query parameter
$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    die(json_encode(["error" => "user_id parameter is required"]));
}

// Get unread count
$stmt = $conn->prepare("SELECT COUNT(*) as count FROM student_notifications 
                       WHERE user_id = ? AND status = 'Unread'");
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

echo json_encode([
    "success" => true,
    "count" => $row['count']
]);

$stmt->close();
$conn->close();
?>