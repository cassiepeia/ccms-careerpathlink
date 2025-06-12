<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Disable HTML error output
ini_set('display_errors', 0);
error_reporting(0);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$response = ['success' => false, 'error' => ''];

try {
    $conn = new mysqli($servername, $username, $password, $database);

    if ($conn->connect_error) {
        throw new Exception("Database Connection Failed: " . $conn->connect_error);
    }

    $conn->set_charset("utf8");

    $appointmentId = null;
    
    // Check for GET parameter
    if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['appointment_id'])) {
        $appointmentId = $_GET['appointment_id'];
    } 
    // Check for POST JSON body
    elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $json = file_get_contents('php://input');
        $data = json_decode($json, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception("Invalid JSON input");
        }
        
        if (isset($data['appointment_id'])) {
            $appointmentId = $data['appointment_id'];
        } elseif (isset($data['coach_id'])) {
            // Handle coach_id case if needed
            $coachId = $data['coach_id'];
        }
    }
    
    if ($appointmentId !== null) {
        $query = "SELECT rr.*, a.service_type, a.student_name
                  FROM reschedule_requests rr
                  JOIN appointments a ON rr.appointment_id = a.id
                  WHERE rr.appointment_id = ?";
        
        $stmt = $conn->prepare($query);
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("i", $appointmentId);
    } elseif (isset($coachId)) {
        $query = "SELECT rr.*, a.service_type, a.student_name
                  FROM reschedule_requests rr
                  JOIN appointments a ON rr.appointment_id = a.id
                  WHERE a.coach_id = ? AND rr.status = 'Pending'";
        
        $stmt = $conn->prepare($query);
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param("i", $coachId);
    } else {
        throw new Exception("Either appointment_id or coach_id is required");
    }
    
    if (!$stmt->execute()) {
        throw new Exception("Execute failed: " . $stmt->error);
    }
    
    $result = $stmt->get_result();
    $rescheduleRequests = [];
    
    while ($row = $result->fetch_assoc()) {
        $rescheduleRequests[] = $row;
    }
    
    $response = [
        'success' => true,
        'data' => $rescheduleRequests
    ];
} catch (Exception $e) {
    $response['error'] = $e->getMessage();
} finally {
    if (isset($conn)) {
        $conn->close();
    }
    
    // Ensure we only output JSON
    header('Content-Type: application/json');
    echo json_encode($response);
    exit;
}