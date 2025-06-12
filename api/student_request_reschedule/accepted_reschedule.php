<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: PUT");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Database Connection Failed: " . $conn->connect_error]);
    exit;
}

$conn->set_charset("utf8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(["error" => "Invalid JSON input"]);
        exit;
    }

    if (!isset($data['id']) || empty($data['id'])) {
        http_response_code(400);
        echo json_encode(["error" => "Reschedule Request ID is required"]);
        exit;
    }
    if (!isset($data['coach_id']) || empty($data['coach_id'])) {
        http_response_code(400);
        echo json_encode(["error" => "Coach ID is required"]);
        exit;
    }

    $id = $conn->real_escape_string($data['id']);
    $coach_id = $conn->real_escape_string($data['coach_id']);
    $coach_reply = isset($data['coach_reply']) ? $conn->real_escape_string($data['coach_reply']) : '';
    
    $conn->begin_transaction();
    
    try {
        $get_request_query = "SELECT * FROM reschedule_requests WHERE id = '$id'";
        $request_result = $conn->query($get_request_query);
        
        if (!$request_result || $request_result->num_rows === 0) {
            throw new Exception("Reschedule request not found");
        }
        
        $request_data = $request_result->fetch_assoc();
        
        $update_query = "UPDATE reschedule_requests 
                         SET status = 'Accepted', 
                             coach_reply = '$coach_reply', 
                             reply_date = NOW(), 
                             reply_by = '$coach_id' 
                         WHERE id = '$id'";

        if (!$conn->query($update_query)) {
            throw new Exception("Failed to update reschedule request: " . $conn->error);
        }
        
        // Updated query to use student_profiles table instead of users table
        $student_id_query = "SELECT user_id FROM student_profiles WHERE student_name = '{$request_data['student_name']}'";
        $student_id_result = $conn->query($student_id_query);
        
        if ($student_id_result && $student_id_result->num_rows > 0) {
            $student_id_row = $student_id_result->fetch_assoc();
            $user_id = $student_id_row['user_id'];
            
            $appointment_query = "SELECT service_type FROM appointments WHERE id = '{$request_data['appointment_id']}'";
            $appointment_result = $conn->query($appointment_query);
            $service_type = "Career Coaching";
            if ($appointment_result && $appointment_result->num_rows > 0) {
                $appointment_row = $appointment_result->fetch_assoc();
                $service_type = $appointment_row['service_type'];
            }
            
            $notification_query = "INSERT INTO student_notifications 
                                 (user_id, notification_type, appointment_id, service_type, 
                                  date_requested, time_requested, message, status) 
                                 VALUES 
                                 ('$user_id', 'Accepted Reschedule Request', '{$request_data['appointment_id']}', 
                                  '$service_type', '{$request_data['date_request']}', '{$request_data['time_request']}', 
                                  '$coach_reply', 'Unread')";
            
            if (!$conn->query($notification_query)) {
                throw new Exception("Failed to create notification: " . $conn->error);
            }
        }
        
        $conn->commit();
        
        http_response_code(200);
        echo json_encode([
            "success" => true,
            "message" => "Reschedule request accepted successfully",
            "updated_fields" => [
                "status" => "Accepted",
                "coach_reply" => $coach_reply,
                "reply_date" => date("Y-m-d H:i:s"),
                "reply_by" => $coach_id
            ]
        ]);
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        echo json_encode(["error" => $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(["error" => "Invalid request method. Use PUT."]);
}

$conn->close();
?>