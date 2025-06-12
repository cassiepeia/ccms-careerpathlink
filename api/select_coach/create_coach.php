<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

$servername = "localhost";
$username = "root"; // Default for Laragon
$password = ""; // Default for Laragon
$dbname = "final_careercoaching"; // Change this to your actual DB name

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed"]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['coach_name']) && isset($data['coach_role'])) {
    $coach_name = $data['coach_name'];
    $coach_role = $data['coach_role'];

    $sql = "INSERT INTO coaches (coach_name, coach_role) VALUES ('$coach_name', '$coach_role')";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["message" => "Coach created successfully"]);
    } else {
        echo json_encode(["error" => "Failed to create coach"]);
    }
} else {
    echo json_encode(["error" => "Missing required fields"]);
}

$conn->close();
?>
