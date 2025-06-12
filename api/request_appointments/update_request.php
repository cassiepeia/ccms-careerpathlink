<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT');
header('Access-Control-Allow-Headers: Content-Type');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed"]);
    exit;
}

$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

if (!empty($data) && isset($data["id"], $data["date_requested"], $data["time_requested"])) {
    $id = $conn->real_escape_string($data["id"]);
    $date_requested = $conn->real_escape_string($data["date_requested"]);
    $time_requested = $conn->real_escape_string($data["time_requested"]);

    $sql = "UPDATE request_appointments SET date_requested = ?, time_requested = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssi", $date_requested, $time_requested, $id);

    if ($stmt->execute()) {
        echo json_encode(["success" => "Appointment updated successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update appointment"]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid input"]);
}

$conn->close();
?>
