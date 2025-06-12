<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database connection failed"]);
    exit();
}

if (!isset($_GET["coach_id"])) {
    echo json_encode(["error" => "Coach ID is required"]);
    exit();
}

$coach_id = $conn->real_escape_string($_GET["coach_id"]);

// First check if this is a user_id (from users table) and get the corresponding coach_id
$sql = "SELECT c.id FROM coaches c JOIN users u ON c.user_id = u.id WHERE u.user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $coach_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $coach_id = $row['id'];
} else {
    // If not found as user_id, assume it's already a coach_id
    $coach_id = intval($coach_id);
}

// Get all time slots for this coach
$sql = "SELECT * FROM time_slots WHERE coach_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $coach_id);
$stmt->execute();
$result = $stmt->get_result();

$timeSlots = [];
while ($row = $result->fetch_assoc()) {
    // Check for existing appointments in the appointments table
    $checkSql = "SELECT status FROM appointments 
                WHERE coach_id = ? AND date_requested = ? AND time_requested = ?
                ORDER BY id DESC LIMIT 1";
    $checkStmt = $conn->prepare($checkSql);
    $dateFormatted = date('Y-m-d', strtotime($row['date_slot']));
    $timeFormatted = date('H:i:s', strtotime($row['start_time']));
    $checkStmt->bind_param("iss", $coach_id, $dateFormatted, $timeFormatted);
    $checkStmt->execute();
    $checkResult = $checkStmt->get_result();
    
    $status = 'available'; // Default status
    $clickable = true;     // Default clickable state
    
    if ($checkResult->num_rows > 0) {
        $appointment = $checkResult->fetch_assoc();
        $status = $appointment['status']; // Keep original case
        
        // Determine clickable state based on appointment status
        // Only clickable if status is 'Decline' or no appointment exists
        $clickable = ($status == 'Decline');
        
        // If status is 'Pending', 'Accepted', or 'Completed', not clickable
        if (in_array($status, ['Pending', 'Accepted', 'Completed'])) {
            $clickable = false;
        }
    }
    
    // Format response
    $row['start_time'] = date('h:i A', strtotime($row['start_time']));
    $row['end_time'] = date('h:i A', strtotime($row['end_time']));
    $row['date_slot'] = date('F j, Y', strtotime($row['date_slot']));
    $row['status'] = $status;
    $row['clickable'] = $clickable;
    
    $timeSlots[] = $row;
    $checkStmt->close();
}

echo json_encode(["time_slots" => $timeSlots]);
$stmt->close();
$conn->close();
?>