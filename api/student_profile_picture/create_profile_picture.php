<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

// Get user ID
$userId = $_POST['user_id'] ?? '';
if (empty($userId)) {
    die(json_encode(["error" => "User ID is required"]));
}

// Define upload directory (absolute path)
$uploadDir = $_SERVER['DOCUMENT_ROOT'] . '/final_career_coaching/assets/uploaded/';

// Ensure upload directory exists
if (!file_exists($uploadDir)) {
    if (!mkdir($uploadDir, 0755, true)) {
        die(json_encode(["error" => "Failed to create upload directory"]));
    }
}

// Check if file was uploaded
if (!isset($_FILES['profile_picture'])) {
    die(json_encode(["error" => "No file uploaded"]));
}

$file = $_FILES['profile_picture'];
if ($file['error'] !== UPLOAD_ERR_OK) {
    die(json_encode(["error" => "Upload error: " . $file['error']]));
}

// File validation
$maxFileSize = 5 * 1024 * 1024; // 5MB
if ($file['size'] > $maxFileSize) {
    die(json_encode(["error" => "File size exceeds 5MB limit"]));
}

$allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
if (!in_array($file['type'], $allowedTypes)) {
    die(json_encode(["error" => "Only JPG, PNG, and GIF images are allowed"]));
}

// Generate unique filename
$extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$newFileName = "profile_" . $userId . "_" . time() . "." . $extension;
$destPath = $uploadDir . $newFileName;

// Move uploaded file
if (!move_uploaded_file($file['tmp_name'], $destPath)) {
    die(json_encode(["error" => "Failed to move uploaded file"]));
}

// Store the web-accessible path in database
$webPath = "assets/uploaded/" . $newFileName;

// Prepare statement to insert or update
$stmt = $conn->prepare("INSERT INTO student_profile_pictures (user_id, image_path) VALUES (?, ?) ON DUPLICATE KEY UPDATE image_path = ?");
$stmt->bind_param("sss", $userId, $webPath, $webPath);

if (!$stmt->execute()) {
    unlink($destPath); // Delete the uploaded file if DB insert fails
    die(json_encode(["error" => "Database error: " . $stmt->error]));
}

// Return success response with full URL
$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
$host = $_SERVER['HTTP_HOST'];
$imageUrl = $protocol . "://$host/final_career_coaching/" . $webPath;

// Verify file exists before returning
if (!file_exists($destPath)) {
    die(json_encode(["error" => "Uploaded file not found on server"]));
}

echo json_encode([
    "success" => true, 
    "image_path" => $webPath,
    "image_url" => $imageUrl
]);

$stmt->close();
$conn->close();
?>