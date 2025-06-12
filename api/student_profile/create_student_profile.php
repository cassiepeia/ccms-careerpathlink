<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed"]);
    exit;
}

$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

if (!empty($data) && isset($data["student_name"], $data["email"])) {
    $student_name = $conn->real_escape_string($data["student_name"]);
    $department = $conn->real_escape_string($data["department"]);
    $course = $conn->real_escape_string($data["course"]);
    $level = $conn->real_escape_string($data["level"]);
    $address = $conn->real_escape_string($data["address"]);
    $contact = $conn->real_escape_string($data["contact"]);
    $email = $conn->real_escape_string($data["email"]);

    $sql = "INSERT INTO student_profiles (student_name, department, course, level, address, contact, email) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssss", $student_name, $department, $course, $level, $address, $contact, $email);
    
    if ($stmt->execute()) {
        echo json_encode(["success" => "Student profile created successfully"]);
    } else {
        echo json_encode(["error" => "Failed to create student profile"]);
    }
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid input"]);
}

$conn->close();
?>
