<?php
// get_slots_with_status.php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed"]));
}

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    die(json_encode(["error" => "Only GET method is allowed"]));
}

$coachId = isset($_GET['coach_id']) ? intval($_GET['coach_id']) : 0;
$date = isset($_GET['date']) ? $conn->real_escape_string($_GET['date']) : '';

if (!$coachId || !$date) {
    die(json_encode(["error" => "Both coach_id and date parameters are required"]));
}

// Get all time slots for the coach and date
$slotsQuery = "SELECT * FROM time_slots WHERE coach_id = $coachId AND date_slot = '$date'";
$slotsResult = $conn->query($slotsQuery);

if (!$slotsResult) {
    die(json_encode(["error" => "Failed to fetch time slots"]));
}

$slots = [];
while ($row = $slotsResult->fetch_assoc()) {
    $slots[] = $row;
}

// Get all appointments that might block these slots
$appointmentsQuery = "SELECT * FROM appointments 
                     WHERE coach_id = $coachId 
                     AND date_requested = '$date'
                     AND status IN ('Pending', 'Accepted', 'Completed')";
$appointmentsResult = $conn->query($appointmentsQuery);

$bookedSlots = [];
if ($appointmentsResult) {
    while ($row = $appointmentsResult->fetch_assoc()) {
        $bookedSlots[$row['time_requested']] = $row['status'];
    }
}

// Merge the data
$response = [];
foreach ($slots as $slot) {
    $startTime = $slot['start_time'];
    $status = isset($bookedSlots[$startTime]) ? $bookedSlots[$startTime] : 'available';
    
    $response[] = [
        'id' => $slot['id'],
        'coach_id' => $slot['coach_id'],
        'date_slot' => $slot['date_slot'],
        'day' => $slot['day'],
        'start_time' => $startTime,
        'end_time' => $slot['end_time'],
        'status' => $status
    ];
}

echo json_encode($response);
$conn->close();