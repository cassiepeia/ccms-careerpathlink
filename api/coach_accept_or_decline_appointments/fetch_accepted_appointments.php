<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit; // Preflight request response
}

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed", "details" => $conn->connect_error]);
    exit;
}

// Query to get accepted appointments that aren't rescheduled (status = 'Accepted')
// Includes flag for pending reschedule requests
$sql = "SELECT 
            ra.id AS request_id, 
            ra.student_name AS name, 
            ra.date_requested AS date, 
            ra.time_requested AS time, 
            ra.service_type,
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM reschedule_requests rr 
                    WHERE rr.appointment_id = ra.appointment_id 
                    AND rr.status = 'Pending'
                ) THEN 1
                ELSE 0
            END AS has_pending_reschedule,
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM reschedule_requests rr 
                    WHERE rr.appointment_id = ra.appointment_id 
                    AND rr.status = 'Accepted'
                ) THEN 1
                ELSE 0
            END AS is_rescheduled
        FROM request_appointments ra
        WHERE ra.status = 'Accepted'
        HAVING is_rescheduled = 0"; // Only show non-rescheduled appointments

$result = $conn->query($sql);

$appointments = [];
while ($row = $result->fetch_assoc()) {
    $appointments[] = $row;
}

echo json_encode($appointments);
$conn->close();
?>