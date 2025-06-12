<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$coach_id = isset($_GET['coach_id']) ? (int)$_GET['coach_id'] : 0;

$sql = "SELECT a.*, r.name, r.profile_image_url 
        FROM appointments a
        JOIN request_appointments r ON a.request_id = r.id
        WHERE a.coach_id = ? AND a.status = 'Accepted'";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $coach_id);
$stmt->execute();
$result = $stmt->get_result();

$appointments = array();
while ($row = $result->fetch_assoc()) {
    $appointments[] = $row;
}

echo json_encode($appointments);

$conn->close();
?>