<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed", "details" => $conn->connect_error]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data["user_id"], $data["date_slot"], $data["day"], $data["start_time"], $data["end_time"])) {
    echo json_encode(["error" => "Missing required fields"]);
    exit;
}

$user_id = $conn->real_escape_string($data["user_id"]);
$date_slot = $conn->real_escape_string($data["date_slot"]);
$day = $conn->real_escape_string($data["day"]);
$start_time = $conn->real_escape_string($data["start_time"]);
$end_time = $conn->real_escape_string($data["end_time"]);

// First, verify the user is a coach
$sql = "SELECT c.id as coach_id, u.id as user_id 
        FROM coaches c 
        JOIN users u ON c.user_id = u.id 
        WHERE u.user_id = ? OR u.id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $user_id, $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $coach = $result->fetch_assoc();
    $coach_id = $coach['coach_id'];
    
    // Check for overlapping time slots
    $checkSql = "SELECT id FROM time_slots 
                WHERE coach_id = ? 
                AND date_slot = ? 
                AND (
                    (start_time < ? AND end_time > ?) OR 
                    (start_time < ? AND end_time > ?) OR 
                    (start_time >= ? AND end_time <= ?)
                )";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param("isssssss", $coach_id, $date_slot, $end_time, $start_time, $start_time, $end_time, $start_time, $end_time);
    $checkStmt->execute();
    $checkResult = $checkStmt->get_result();
    
    if ($checkResult->num_rows > 0) {
        echo json_encode(["error" => "Time slot overlaps with an existing slot"]);
        $checkStmt->close();
        $stmt->close();
        $conn->close();
        exit;
    }
    $checkStmt->close();

    // Insert the new time slot
    $insertSql = "INSERT INTO time_slots (coach_id, date_slot, day, start_time, end_time) VALUES (?, ?, ?, ?, ?)";
    $insertStmt = $conn->prepare($insertSql);
    $insertStmt->bind_param("issss", $coach_id, $date_slot, $day, $start_time, $end_time);

    if ($insertStmt->execute()) {
        $startTimeFormatted = date('h:i A', strtotime($start_time));
        $endTimeFormatted = date('h:i A', strtotime($end_time));
        $dateFormatted = date('F j, Y', strtotime($date_slot));

        echo json_encode([
            "success" => "Time slot created successfully",
            "time_slot" => [
                "id" => $insertStmt->insert_id,
                "coach_id" => $coach_id,
                "date_slot" => $dateFormatted,
                "day" => $day,
                "start_time" => $startTimeFormatted,
                "end_time" => $endTimeFormatted,
                "status" => "available",
                "clickable" => true
            ]
        ]);
    } else {
        echo json_encode(["error" => "Failed to create time slot", "details" => $insertStmt->error]);
    }

    $insertStmt->close();
} else {
    echo json_encode(["error" => "User is not a coach or doesn't exist", "user_id" => $user_id]);
}

$stmt->close();
$conn->close();
?>