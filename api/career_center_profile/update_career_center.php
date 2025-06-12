<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['user_id'])) {
    $user_id = $conn->real_escape_string($data['user_id']);
    $updates = [];
    
    if (isset($data['name'])) $updates[] = "name = '" . $conn->real_escape_string($data['name']) . "'";
    if (isset($data['email'])) $updates[] = "email = '" . $conn->real_escape_string($data['email']) . "'";
    if (isset($data['address'])) $updates[] = "address = " . ($data['address'] ? "'" . $conn->real_escape_string($data['address']) . "'" : "NULL");
    if (isset($data['contact'])) $updates[] = "contact = " . ($data['contact'] ? "'" . $conn->real_escape_string($data['contact']) . "'" : "NULL");
    
    if (!empty($updates)) {
        $sql = "UPDATE career_center_profile SET " . implode(", ", $updates) . " WHERE user_id = '$user_id'";
        
        if ($conn->query($sql)) {
            if ($conn->affected_rows > 0) {
                echo json_encode(["message" => "Profile updated successfully"]);
            } else {
                echo json_encode(["message" => "No changes made or profile not found"]);
            }
        } else {
            echo json_encode(["error" => "Failed to update profile: " . $conn->error]);
        }
    } else {
        echo json_encode(["error" => "No fields to update"]);
    }
} else {
    echo json_encode(["error" => "user_id is required"]);
}

$conn->close();
?>