<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

// Get the POST data
$data = json_decode(file_get_contents("php://input"), true);

if (!empty($data) && isset($data["user_id"], $data["notification_type"])) {
    // Prepare and bind
    $stmt = $conn->prepare("INSERT INTO student_notifications 
                           (user_id, notification_type, appointment_id, service_type, date_requested, time_requested, message) 
                           VALUES (?, ?, ?, ?, ?, ?, ?)");
    
    $stmt->bind_param("ssissss", 
        $data["user_id"],
        $data["notification_type"],
        $data["appointment_id"] ?? null,
        $data["service_type"] ?? null,
        $data["date_requested"] ?? null,
        $data["time_requested"] ?? null,
        $data["message"] ?? null
    );

    // Execute and respond
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "id" => $stmt->insert_id]);
    } else {
        echo json_encode(["error" => "Failed to create notification: " . $stmt->error]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid input: user_id and notification_type are required"]);
}

$conn->close();
?>