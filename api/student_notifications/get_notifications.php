<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "error" => "Database connection failed: " . $conn->connect_error
    ]));
}

$user_id = $_GET['user_id'] ?? '';
if (empty($user_id)) {
    die(json_encode([
        "success" => false,
        "error" => "User ID parameter is required"
    ]));
}

$sql = "SELECT * FROM student_notifications WHERE user_id = ? ORDER BY created_at DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = [
        'id' => $row['id'],
        'user_id' => $row['user_id'],
        'notification_type' => $row['notification_type'],
        'appointment_id' => $row['appointment_id'],
        'service_type' => $row['service_type'],
        'date_requested' => $row['date_requested'],
        'time_requested' => $row['time_requested'],
        'message' => $row['message'],
        'status' => $row['status'],
        'created_at' => $row['created_at'],
        'updated_at' => $row['updated_at']
    ];
}

echo json_encode([
    "success" => true,
    "data" => $notifications,
    "debug" => [
        "user_id" => $user_id,
        "count" => count($notifications)
    ]
]);

$stmt->close();
$conn->close();
?>