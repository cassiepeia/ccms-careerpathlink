<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

error_reporting(E_ALL);
ini_set('display_errors', 0);
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

if (!isset($_GET['appointment_id'])) {
    echo json_encode(["error" => "Missing appointment_id parameter"]);
    exit;
}

$appointment_id = $conn->real_escape_string($_GET['appointment_id']);

$sql = "SELECT * FROM appointment_status_tracking WHERE appointment_id = ? ORDER BY status_date DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $appointment_id);
$stmt->execute();
$result = $stmt->get_result();

$history = [];
while ($row = $result->fetch_assoc()) {
    $history[] = [
        'id' => $row['id'],
        'status' => $row['status'],
        'status_date' => $row['status_date'],
        'message' => $row['message'],
        'date_requested' => $row['date_requested'],
        'time_requested' => $row['time_requested']
    ];
}

echo json_encode($history);

$stmt->close();
$conn->close();
?>