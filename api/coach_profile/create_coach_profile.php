<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed: " . $conn->connect_error]);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $rawData = file_get_contents("php://input");
    $data = json_decode($rawData, true);

    if (!isset($data["user_id"], $data["coach_name"], $data["email"])) {
        echo json_encode(["error" => "Missing required fields (user_id, coach_name, email)"]);
        exit();
    }

    $user_id = $conn->real_escape_string($data["user_id"]);
    $coach_name = $conn->real_escape_string($data["coach_name"]);
    $position = isset($data["position"]) ? $conn->real_escape_string($data["position"]) : null;
    $contact = isset($data["contact"]) ? $conn->real_escape_string($data["contact"]) : null;
    $email = $conn->real_escape_string($data["email"]);

    $sql = "INSERT INTO coach_profiles (user_id, coach_name, position, contact, email) 
            VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $user_id, $coach_name, $position, $contact, $email);

    if ($stmt->execute()) {
        echo json_encode([
            "success" => true,
            "message" => "Coach profile created successfully",
            "id" => $stmt->insert_id
        ]);
    } else {
        echo json_encode([
            "error" => true,
            "message" => "Error creating coach profile: " . $stmt->error
        ]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>