<?php
// update_notification.php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (!empty($data) && isset($data["id"], $data["status"])) {
    $stmt = $conn->prepare("UPDATE student_notifications SET status = ?, updated_at = NOW() WHERE id = ?");
    $stmt->bind_param("si", $data["status"], $data["id"]);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["error" => "No notification found with that ID"]);
        }
    } else {
        echo json_encode(["error" => "Update failed: " . $stmt->error]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid input: id and status are required"]);
}

$conn->close();
?>