<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

// Connect to MySQL
$conn = new mysqli($servername, $username, $password, $database);

// Check for connection error
if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Database Connection Failed: " . $conn->connect_error]);
    exit;
}

// Set character set to UTF-8
$conn->set_charset("utf8");

// Validate request method
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Get coach_id from query parameters
    $coach_id = isset($_GET['coach_id']) ? $conn->real_escape_string($_GET['coach_id']) : null;

    // Validate coach_id
    if (!$coach_id) {
        http_response_code(400);
        echo json_encode(["error" => "Coach ID is required"]);
        exit;
    }

    // Prepare query to get all replies by this coach
    // Modified to use the correct column name (assuming it's 'reply_by' or similar)
    $query = "SELECT 
                rr.id as request_id,
                rr.appointment_id,
                rr.student_name,
                rr.date_request,
                rr.time_request,
                rr.message as student_message,
                rr.coach_reply,
                rr.reply_date,
                rr.status
              FROM reschedule_requests rr
              WHERE rr.coach_id = '$coach_id'  -- Changed from reply_by to coach_id
              ORDER BY rr.reply_date DESC";

    $result = $conn->query($query);

    if ($result) {
        $replies = [];
        while ($row = $result->fetch_assoc()) {
            $replies[] = [
                'request_id' => $row['request_id'],
                'appointment_id' => $row['appointment_id'],
                'student_name' => $row['student_name'],
                'request_date' => $row['date_request'],
                'request_time' => $row['time_request'],
                'student_message' => $row['student_message'],
                'coach_reply' => $row['coach_reply'],
                'reply_date' => $row['reply_date'],
                'status' => $row['status']
            ];
        }

        http_response_code(200);
        echo json_encode([
            "success" => true,
            "replies" => $replies,
            "count" => count($replies)
        ]);
    } else {
        http_response_code(500);
        echo json_encode(["error" => "Failed to fetch replies: " . $conn->error]);
    }
} else {
    http_response_code(405);
    echo json_encode(["error" => "Invalid request method. Use GET."]);
}

$conn->close();
?>