<?php
// 1. CORS Headers (MUST come first)
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// 2. Timezone Setting
date_default_timezone_set('UTC');

// 3. Then your other headers
header('Content-Type: application/json');

// 4. Error reporting (optional but recommended)
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

// 5. Then your database connection and logic
$conn = new mysqli("localhost", "root", "", "final_careercoaching");

if ($conn->connect_error) {
    echo json_encode(["success" => false, "error" => "Database Connection Failed", "details" => $conn->connect_error]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    error_log("Received GET request for unread count: " . print_r($_GET, true));
    
    if (isset($_GET['user_id'])) {
        $user_id = $conn->real_escape_string($_GET['user_id']);
        $sql = "SELECT COUNT(*) as unread_count FROM wdt_notifications WHERE user_id = ? AND status = 'Unread'";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $user_id);
    } elseif (isset($_GET['student_name'])) {
        $student_name = $conn->real_escape_string($_GET['student_name']);
        $sql = "SELECT COUNT(*) as unread_count FROM wdt_notifications WHERE student_name = ? AND status = 'Unread'";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("s", $student_name);
    } else {
        echo json_encode(["success" => false, "error" => "Missing parameters"]);
        exit;
    }

    if ($stmt->execute()) {
        $result = $stmt->get_result();
        $count = $result->fetch_assoc()['unread_count'];
        echo json_encode(["success" => true, "unread_count" => (int)$count]);
    } else {
        echo json_encode(["success" => false, "error" => "Failed to get unread count", "details" => $stmt->error]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["success" => false, "error" => "Invalid request method"]);
}

$conn->close();
?>