<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

// Connect to database
$mysqli = new mysqli("localhost", "root", "", "final_careercoaching");

if ($mysqli->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $mysqli->connect_error]));
}

// Decode JSON request
$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["error" => "Invalid JSON received"]);
    exit;
}

// Validate required fields
if (!isset($data['student_no']) || empty(trim($data['student_no']))) {
    echo json_encode(["error" => "Student number is required"]);
    exit;
}

// Assign variables (Allow NULL values)
$student_no = $mysqli->real_escape_string($data['student_no']);
$name = isset($data['student_name']) ? $mysqli->real_escape_string($data['student_name']) : null;
$department = isset($data['department']) && !empty($data['department']) ? $mysqli->real_escape_string($data['department']) : null;
$course = isset($data['course']) && !empty($data['course']) ? $mysqli->real_escape_string($data['course']) : null;
$level = isset($data['level']) && !empty($data['level']) ? $mysqli->real_escape_string($data['level']) : null;
$address = isset($data['address']) && !empty($data['address']) ? $mysqli->real_escape_string($data['address']) : null;
$contact = isset($data['contact']) && !empty($data['contact']) ? $mysqli->real_escape_string($data['contact']) : null;
$email = isset($data['email']) ? $mysqli->real_escape_string($data['email']) : null;

// Check if user exists
$checkUser = $mysqli->prepare("SELECT user_id FROM users WHERE user_id = ?");
$checkUser->bind_param("s", $student_no);
$checkUser->execute();
$checkUser->store_result();

if ($checkUser->num_rows == 0) {
    echo json_encode(["error" => "User with ID $student_no not found"]);
    exit;
}
$checkUser->close();

// ✅ Update `users` table first
$query1 = $mysqli->prepare("UPDATE users SET name = ?, email = ? WHERE user_id = ?");
if ($query1) {
    $query1->bind_param("sss", $name, $email, $student_no);
    $query1->execute();
    $query1->close();
}

// ✅ Then, update `student_profiles` table
$query2 = $mysqli->prepare("UPDATE student_profiles 
    SET student_name = ?, 
        department = COALESCE(?, department), 
        course = COALESCE(?, course), 
        level = COALESCE(?, level), 
        address = COALESCE(?, address), 
        contact = COALESCE(?, contact), 
        email = COALESCE(?, email) 
    WHERE user_id = ?");

if (!$query2) {
    echo json_encode(["error" => "Prepare failed: " . $mysqli->error]);
    exit;
}

$query2->bind_param("ssssssss", $name, $department, $course, $level, $address, $contact, $email, $student_no);

if ($query2->execute()) {
    echo json_encode(["success" => "Student information updated successfully"]);
} else {
    echo json_encode(["error" => "Error updating student information: " . $query2->error]);
}

$query2->close();
$mysqli->close();
?>
