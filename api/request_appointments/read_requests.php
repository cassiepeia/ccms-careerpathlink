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
    error_log("Fetching appointments for coach ID: $coach_id");

    $stmt = $conn->prepare("
        SELECT ra.id, ra.student_name, ra.date_requested, ra.time_requested, 
               '' AS profile_image_url,
               a.coach_id,
               ra.service_type
        FROM request_appointments ra
        JOIN appointments a ON ra.appointment_id = a.id
        WHERE ra.status = 'Pending' AND a.coach_id = ?
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