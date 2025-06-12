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
    error_log("Connection failed: " . $conn->connect_error);
    die(json_encode([
        "success" => false,
        "error" => "Database connection failed",
        "details" => $conn->connect_error
    ]));
}

try {
    $method = $_SERVER['REQUEST_METHOD'];
    error_log("Request method: $method");
    error_log("GET parameters: " . print_r($_GET, true));

    if ($method === 'GET') {
        if (isset($_GET['user_id'])) {
            $user_id = $conn->real_escape_string($_GET['user_id']);
            error_log("Fetching notifications for user_id: $user_id");
            
            $stmt = $conn->prepare("
                SELECT 
                    id, user_id, student_name, notification_type,
                    appointment_id, service_type, 
                    DATE_FORMAT(date_requested, '%Y-%m-%d') as date_requested,
                    TIME_FORMAT(time_requested, '%H:%i:%s') as time_requested,
                    message, status,
                    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
                    DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
                FROM wdt_notifications 
                WHERE user_id = ?
                ORDER BY created_at DESC
            ");
            $stmt->bind_param("s", $user_id);
        } 
        elseif (isset($_GET['student_name'])) {
            $student_name = $conn->real_escape_string($_GET['student_name']);
            error_log("Fetching notifications for student: $student_name");
            
            $stmt = $conn->prepare("
                SELECT 
                    id, user_id, student_name, notification_type,
                    appointment_id, service_type, 
                    DATE_FORMAT(date_requested, '%Y-%m-%d') as date_requested,
                    TIME_FORMAT(time_requested, '%H:%i:%s') as time_requested,
                    message, status,
                    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as created_at,
                    DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') as updated_at
                FROM wdt_notifications 
                WHERE student_name = ?
                ORDER BY created_at DESC
            ");
            $stmt->bind_param("s", $student_name);
        }
        else {
            throw new Exception("Missing user_id or student_name parameter");
        }

        if (!$stmt->execute()) {
            throw new Exception("Execute failed: " . $stmt->error);
        }

        $result = $stmt->get_result();
        $notifications = [];
        
        while ($row = $result->fetch_assoc()) {
            $notifications[] = [
                'id' => $row['id'],
                'user_id' => $row['user_id'],
                'student_name' => $row['student_name'],
                'notification_type' => $row['notification_type'],
                'appointment_id' => $row['appointment_id'],
                'service_type' => $row['service_type'],
                'date_requested' => $row['date_requested'],
                'time_requested' => $row['time_requested'],
                'message' => $row['message'],
                'status' => $row['status'],
                'created_at' => $row['created_at'],
                'updated_at' => $row['updated_at']
            ];
        }
        
        error_log("Found notifications: " . count($notifications));
        echo json_encode([
            "success" => true,
            "notifications" => $notifications
        ]);
    }
    else {
        throw new Exception("Invalid request method");
    }
} 
catch (Exception $e) {
    error_log("Error: " . $e->getMessage());
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
}
?>