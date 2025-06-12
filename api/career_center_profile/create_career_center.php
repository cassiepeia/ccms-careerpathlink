<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
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

if (isset($data['user_id']) && isset($data['name']) && isset($data['email'])) {
    $user_id = $conn->real_escape_string($data['user_id']);
    $name = $conn->real_escape_string($data['name']);
    $email = $conn->real_escape_string($data['email']);
    $address = isset($data['address']) ? $conn->real_escape_string($data['address']) : null;
    $contact = isset($data['contact']) ? $conn->real_escape_string($data['contact']) : null;

    $sql = "INSERT INTO career_center_profile (user_id, name, email, address, contact) 
            VALUES ('$user_id', '$name', '$email', " . ($address ? "'$address'" : "NULL") . ", " . ($contact ? "'$contact'" : "NULL") . ")";
    
    if ($conn->query($sql)) {
        echo json_encode(["message" => "Career Center profile created successfully"]);
    } else {
        echo json_encode(["error" => "Failed to create profile: " . $conn->error]);
    }
} else {
    echo json_encode(["error" => "Missing required fields: user_id, name, and email are required"]);
}

$conn->close();
?>