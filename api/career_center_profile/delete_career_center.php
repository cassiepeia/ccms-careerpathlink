<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE");
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
    
    $sql = "DELETE FROM career_center_profile WHERE user_id = '$user_id'";
    
    if ($conn->query($sql)) {
        if ($conn->affected_rows > 0) {
            echo json_encode(["message" => "Profile deleted successfully"]);
        } else {
            echo json_encode(["message" => "No profile found with that user_id"]);
        }
    } else {
        echo json_encode(["error" => "Failed to delete profile: " . $conn->error]);
    }
} else {
    echo json_encode(["error" => "user_id is required"]);
}

$conn->close();
?>