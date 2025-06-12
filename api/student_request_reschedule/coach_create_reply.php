<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$response = [];

try {
    $conn = new mysqli($servername, $username, $password, $database);

    if ($conn->connect_error) {
        throw new Exception("Database Connection Failed: " . $conn->connect_error);
    }

    $conn->set_charset("utf8");

    // Handle OPTIONS request for CORS preflight
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
        throw new Exception("Invalid request method. Received " . $_SERVER['REQUEST_METHOD'] . " but expected PUT.");
    }

    $input = json_decode(file_get_contents('php://input'), true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception("Invalid JSON input: " . json_last_error_msg());
    }

    if (!isset($input['id']) || empty($input['id'])) {
        throw new Exception("Reschedule Request ID is required");
    }
    if (!isset($input['coach_reply']) || empty($input['coach_reply'])) {
        throw new Exception("Reply message is required");
    }
    if (!isset($input['coach_id']) || empty($input['coach_id'])) {
        throw new Exception("Coach ID is required");
    }

    // Prepare the SQL statement with parameterized queries
    $stmt = $conn->prepare("UPDATE reschedule_requests SET 
        coach_reply = ?,
        reply_date = ?,
        reply_by = ?
        WHERE id = ?");
    
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }

    $current_datetime = date('Y-m-d H:i:s');
    $stmt->bind_param("sssi", 
        $input['coach_reply'],
        $current_datetime,
        $input['coach_id'],
        $input['id']
    );

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            $response = [
                "success" => true,
                "message" => "Reply submitted successfully",
                "data" => [
                    "id" => $input['id'],
                    "reply_date" => $current_datetime,
                    "coach_reply" => $input['coach_reply']
                ]
            ];
        } else {
            throw new Exception("No reschedule request found with ID: " . $input['id'] . " or no changes made");
        }
    } else {
        throw new Exception("Failed to submit reply: " . $stmt->error);
    }
    
    $stmt->close();
} catch (Exception $e) {
    http_response_code(500);
    $response = [
        "success" => false,
        "error" => $e->getMessage()
    ];
} finally {
    if (isset($conn)) {
        $conn->close();
    }
    
    echo json_encode($response);
    exit;
}