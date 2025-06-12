<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: DELETE');
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

// Get the DELETE data
$data = json_decode(file_get_contents("php://input"), true);

if (!empty($data) && isset($data["id"])) {
    $stmt = $conn->prepare("DELETE FROM student_notifications WHERE id = ?");
    $stmt->bind_param("i", $data["id"]);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["error" => "No notification found with that ID"]);
        }
    } else {
        echo json_encode(["error" => "Delete failed: " . $stmt->error]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid input: id is required"]);
}

$conn->close();
?>