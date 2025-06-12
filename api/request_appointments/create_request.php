<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed: " . $conn->connect_error]);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $rawData = file_get_contents("php://input");
    file_put_contents("debug_log.txt", "Raw JSON Data: " . $rawData . "\n", FILE_APPEND);
    
    $data = json_decode($rawData, true);
    file_put_contents("debug_log.txt", "Decoded Data: " . print_r($data, true) . "\n", FILE_APPEND);

    if (!isset($data["user_id"], $data["date_requested"], $data["time_requested"], $data["coach_id"], $data["service_type"])) {
        echo json_encode([
            "error" => "Missing required fields.",
            "received" => $data
        ]);
        exit();
    }

    $user_id = $conn->real_escape_string($data["user_id"]);
    $date_requested = $conn->real_escape_string($data["date_requested"]);
    $coach_id = (int)$data["coach_id"]; // Ensure coach_id is an integer
    $service_type = $conn->real_escape_string($data["service_type"]);
    $time_requested_12h = $data["time_requested"];
    $time_requested_24h = date("H:i:s", strtotime($time_requested_12h));
    $time_requested = $conn->real_escape_string($time_requested_24h);

    // Get student name
    $student_sql = "SELECT student_name FROM student_profiles WHERE user_id = ?";
    $student_stmt = $conn->prepare($student_sql);
    $student_stmt->bind_param("s", $user_id);
    $student_stmt->execute();
    $student_result = $student_stmt->get_result();

    if ($student_result->num_rows === 0) {
        echo json_encode(["error" => "Student not found"]);
        exit();
    }

    $student_row = $student_result->fetch_assoc();
    $student_name = $student_row['student_name'];
    $student_stmt->close();

    // Get WDT's user ID (for notifications)
    $wdt_user_id = null;
    $wdt_sql = "SELECT u.id FROM users u JOIN coaches c ON u.id = c.user_id WHERE c.id = ?";
    $wdt_stmt = $conn->prepare($wdt_sql);
    $wdt_stmt->bind_param("i", $coach_id);
    $wdt_stmt->execute();
    $wdt_result = $wdt_stmt->get_result();

    if ($wdt_result->num_rows > 0) {
        $wdt_row = $wdt_result->fetch_assoc();
        $wdt_user_id = $wdt_row['id'];
    }
    $wdt_stmt->close();

    // Begin transaction
    $conn->begin_transaction();

    try {
        // First insert into appointments table with service_type and coach_id
        $insert_appointment_sql = "INSERT INTO appointments (student_name, date_requested, time_requested, status, coach_id, service_type, wdt_user_id) 
                                 VALUES (?, ?, ?, 'Pending', ?, ?, ?)";
        $insert_appointment_stmt = $conn->prepare($insert_appointment_sql);
        $insert_appointment_stmt->bind_param("sssisi", $student_name, $date_requested, $time_requested, $coach_id, $service_type, $wdt_user_id);
        
        if (!$insert_appointment_stmt->execute()) {
            throw new Exception("Failed to create appointment: " . $insert_appointment_stmt->error);
        }
        
        $appointment_id = $insert_appointment_stmt->insert_id;
        $insert_appointment_stmt->close();

        // Then insert into request_appointments table (with service_type and coach_id)
        $insert_request_sql = "INSERT INTO request_appointments (appointment_id, student_name, date_requested, time_requested, status, service_type, coach_id)
                              VALUES (?, ?, ?, ?, 'Pending', ?, ?)";
        $insert_request_stmt = $conn->prepare($insert_request_sql);
        $insert_request_stmt->bind_param("issssi", $appointment_id, $student_name, $date_requested, $time_requested, $service_type, $coach_id);
        
        if (!$insert_request_stmt->execute()) {
            throw new Exception("Failed to create request appointment: " . $insert_request_stmt->error);
        }
        
        $insert_request_stmt->close();
        
        $conn->commit();
        echo json_encode(["success" => "Appointment booked successfully", "appointment_id" => $appointment_id]);
    } catch (Exception $e) {
        $conn->rollback();
        echo json_encode(["error" => $e->getMessage()]);
    }
    
    exit();
}

// Handle GET request for fetching booked slots
if ($_SERVER["REQUEST_METHOD"] === "GET") {
    try {
        $query = "SELECT date_requested, time_requested, status, service_type, coach_id FROM appointments";
        $result = $conn->query($query);
        
        if (!$result) {
            throw new Exception("Failed to fetch booked slots: " . $conn->error);
        }
        
        $booked_slots = [];
        while ($row = $result->fetch_assoc()) {
            $booked_slots[] = [
                'date_requested' => $row['date_requested'],
                'time_requested' => $row['time_requested'],
                'status' => $row['status'],
                'service_type' => $row['service_type'],
                'coach_id' => $row['coach_id']
            ];
        }
        
        echo json_encode(['booked_slots' => $booked_slots]);
    } catch (Exception $e) {
        echo json_encode(["error" => $e->getMessage()]);
    }
    
    exit();
}

$conn->close();
?>