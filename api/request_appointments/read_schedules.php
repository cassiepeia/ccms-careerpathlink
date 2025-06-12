<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'error' => 'Database connection failed'
    ]));
}

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    
    if (!isset($data['coach_id'])) {
        die(json_encode([
            'success' => false,
            'error' => 'Coach ID is required'
        ]));
    }

    $coach_id = (int)$data['coach_id'];
    error_log("Fetching schedules for coach ID: $coach_id");

    $stmt = $conn->prepare("
    SELECT 
        a.id,
        a.student_name,
        a.date_requested,
        a.time_requested,
        a.service_type,
        a.status,
        '' AS profile_image_url,
        a.coach_id,
        CASE WHEN cr.id IS NOT NULL THEN 1 ELSE 0 END AS has_pending_reschedule
    FROM 
        appointments a
    LEFT JOIN 
        reschedule_requests rr ON a.id = rr.appointment_id AND rr.status = 'Pending'
    LEFT JOIN
        coach_cancellation_requests cr ON a.id = cr.appointment_id AND cr.status = 'Pending'
    WHERE 
        a.coach_id = ? 
        AND a.status = 'Accepted'  -- Changed from IN ('Accepted', 'Completed') to just 'Accepted'
    ORDER BY 
        a.date_requested ASC, a.time_requested ASC
");
    
    $stmt->bind_param("i", $coach_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $appointments = [];
    while ($row = $result->fetch_assoc()) {
        $appointments[] = $row;
    }
    
    $stmt->close();
    
    echo json_encode([
        'success' => true,
        'data' => $appointments,
        'count' => count($appointments),
        'debug' => [
            'coach_id' => $coach_id,
            'num_appointments' => count($appointments)
        ]
    ]);

} catch (Exception $e) {
    error_log("Error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} finally {
    $conn->close();
}
?>