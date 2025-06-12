<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$postData = file_get_contents("php://input");
$data = json_decode($postData, true);

if (!isset($data['user_id'])) {
    http_response_code(400);
    die(json_encode(["error" => "user_id is required"]));
}

$userId = $conn->real_escape_string($data['user_id']);

$stmt = $conn->prepare("SELECT image_path FROM student_profile_pictures WHERE user_id = ?");
if (!$stmt) {
    die(json_encode(["error" => "Prepare failed: " . $conn->error]));
}

$stmt->bind_param("s", $userId);
if (!$stmt->execute()) {
    die(json_encode(["error" => "Execute failed: " . $stmt->error]));
}

$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $imagePath = $row['image_path'];
    
    // Verify the image exists before returning
    $imageFullPath = $_SERVER['DOCUMENT_ROOT'] . '/final_career_coaching/' . $imagePath;
    
    if (!file_exists($imageFullPath)) {
        error_log("Image file not found at path: $imageFullPath");
        echo json_encode([
            "error" => "Image file not found on server",
            "debug" => [
                "image_path" => $imagePath,
                "full_path" => $imageFullPath,
                "document_root" => $_SERVER['DOCUMENT_ROOT']
            ]
        ]);
        exit;
    }
    
    // Construct full URL with proper protocol
    $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
    $host = $_SERVER['HTTP_HOST'];
    $imageUrl = $protocol . "://$host/final_career_coaching/" . $imagePath;
    
    echo json_encode([
        'success' => true,
        'image_path' => $imagePath,
        'image_url' => $imageUrl
    ]);
} else {
    echo json_encode([
        "error" => "No profile picture found",
        "debug" => ["received_user_id" => $userId]
    ]);
}

$stmt->close();
$conn->close();
?>