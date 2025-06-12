<?php
// Start output buffering
ob_start();

// Add debug logging
error_log("SCRIPT STARTED - read_cancellation_requests.php");
file_put_contents('debug.log', date('Y-m-d H:i:s') . " - Script started\n", FILE_APPEND);

// Set headers first
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

// Handle OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

try {
    $conn = new mysqli($servername, $username, $password, $database);
    
    if ($conn->connect_error) {
        throw new Exception("Database Connection Failed: " . $conn->connect_error);
    }

    // Check if we're getting a specific request or all requests
    if (isset($_GET['id'])) {
        // Get single cancellation request by ID with coach name
        $id = $conn->real_escape_string($_GET['id']);
        $query = "SELECT ccr.*, c.coach_name 
                  FROM coach_cancellation_requests ccr
                  JOIN coaches c ON ccr.coach_id = c.id
                  WHERE ccr.id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            throw new Exception("Cancellation request not found");
        }
        
        $request = $result->fetch_assoc();
        $response = ["success" => true, "data" => $request];
    } elseif (isset($_GET['appointment_id'])) {
        // Get cancellation request by appointment ID
        $appointment_id = $conn->real_escape_string($_GET['appointment_id']);
        $query = "SELECT ccr.*, c.coach_name 
                  FROM coach_cancellation_requests ccr
                  JOIN coaches c ON ccr.coach_id = c.id
                  WHERE ccr.appointment_id = ?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $appointment_id);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $requests = [];
        while ($row = $result->fetch_assoc()) {
            $requests[] = $row;
        }
        
        $response = ["success" => true, "data" => $requests];
    } else {
        // Get all cancellation requests with coach names and optional filters
        $coach_id = isset($_GET['coach_id']) ? $conn->real_escape_string($_GET['coach_id']) : null;
        $student_name = isset($_GET['student_name']) ? $conn->real_escape_string($_GET['student_name']) : null;
        $status = isset($_GET['status']) ? $conn->real_escape_string($_GET['status']) : null;
        
        // Base query with JOIN to get coach_name
        $query = "SELECT ccr.*, c.coach_name 
                  FROM coach_cancellation_requests ccr
                  JOIN coaches c ON ccr.coach_id = c.id
                  WHERE 1=1";
        
        $params = [];
        $types = "";
        
        if ($coach_id) {
            $query .= " AND ccr.coach_id = ?";
            $params[] = $coach_id;
            $types .= "i";
        }
        
        if ($student_name) {
            $query .= " AND ccr.student_name LIKE ?";
            $params[] = '%' . $student_name . '%';
            $types .= "s";
        }
        
        if ($status) {
            $query .= " AND ccr.status = ?";
            $params[] = $status;
            $types .= "s";
        }
        
        $query .= " ORDER BY ccr.request_date DESC";
        
        $stmt = $conn->prepare($query);
        if (!empty($params)) {
            $stmt->bind_param($types, ...$params);
        }
        $stmt->execute();
        $result = $stmt->get_result();
        
        $requests = [];
        while ($row = $result->fetch_assoc()) {
            $requests[] = $row;
        }
        
        $response = ["success" => true, "data" => $requests];
    }
    
    // Clear any output buffer and send success response
    ob_end_clean();
    echo json_encode($response);
    exit;
    
} catch (Exception $e) {
    // Clear output buffer and send error
    ob_end_clean();
    http_response_code(400);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}
?>