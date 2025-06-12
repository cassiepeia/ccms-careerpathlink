<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

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

// Validate user_id parameter
if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
    http_response_code(400);
    echo json_encode(["error" => "User ID is required"]);
    exit;
}

$user_id = $conn->real_escape_string($_GET['user_id']);
$current_date = date('Y-m-d');
$current_time = date('H:i:s');

try {
    // Fetch student name using user_id
    $student_query = "SELECT student_name FROM student_profiles WHERE user_id = ?";
    $stmt = $conn->prepare($student_query);
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $student_result = $stmt->get_result();

    if ($student_result->num_rows === 0) {
        http_response_code(404);
        echo json_encode(["error" => "Student not found"]);
        exit;
    }

    $student_row = $student_result->fetch_assoc();
    $student_name = $student_row['student_name'];

    // Modified query to get all appointments with their service types
    $sql = "SELECT 
                a.id AS appointment_id,
                a.date_requested AS session_date, 
                a.time_requested AS session_time, 
                a.coach_id, 
                a.student_name, 
                a.status, 
                a.service_type,
                c.coach_name,
                s.id AS session_id
            FROM appointments a
            LEFT JOIN sessions s ON s.appointment_id = a.id
            JOIN coaches c ON a.coach_id = c.id
            WHERE a.student_name = ?
            ORDER BY a.date_requested DESC, a.time_requested DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $student_name);
    $stmt->execute();
    $result = $stmt->get_result();

    $sessions = [
        "upcoming_sessions" => [],
        "past_sessions" => [],
        "pending_sessions" => [],
        "cancelled_sessions" => [],
    ];

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $session = [
                "session_id" => $row['session_id'],
                "appointment_id" => $row['appointment_id'],
                "session_date" => $row['session_date'],
                "session_time" => $row['session_time'],
                "coach_id" => $row['coach_id'],
                "student_name" => $row['student_name'],
                "status" => $row['status'],
                "coach_name" => $row['coach_name'],
                "service_type" => $row['service_type']
            ];
            
            $session_date = $row['session_date'];
            $session_time = $row['session_time'];
            
            // Categorize sessions based on status and date/time
            switch ($row['status']) {
                case 'Pending':
                    $sessions["pending_sessions"][] = $session;
                    break;
                case 'Cancelled':
                case 'RESCHEDULE': // IDADAGDAG LANG ITO
                    $sessions["cancelled_sessions"][] = $session;
                    break;
                case 'Accepted':
                    if (strtotime($session_date) > strtotime($current_date) || 
                       (strtotime($session_date) == strtotime($current_date) && strtotime($session_time) > strtotime($current_time))) {
                        $sessions["upcoming_sessions"][] = $session;
                    } else {
                        $sessions["past_sessions"][] = $session;
                    }
                    break;
                case 'Completed':
                    $sessions["past_sessions"][] = $session;
                    break;
            }
        }
    }

    echo json_encode([
        "success" => true,
        "upcoming_sessions" => $sessions["upcoming_sessions"],
        "past_sessions" => $sessions["past_sessions"],
        "pending_sessions" => $sessions["pending_sessions"],
        "cancelled_sessions" => $sessions["cancelled_sessions"],
        "message" => "Sessions retrieved successfully"
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Database Error",
        "details" => $e->getMessage(),
        "trace" => $e->getTraceAsString()
    ]);
} finally {
    $conn->close();
}
?>