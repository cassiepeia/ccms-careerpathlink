<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Methods, Access-Control-Allow-Origin");

$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "final_careercoaching"; 

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed"]));
}

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    die(json_encode(["error" => "Invalid request method"]));
}

$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

if (!isset($data['id']) || empty($data['id'])) {
    echo json_encode(["error" => "Missing time slot ID"]);
    exit;
}

$id = $conn->real_escape_string($data['id']);
$sql = "DELETE FROM time_slots WHERE id = '$id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["message" => "Time slot deleted successfully"]);
} else {
    echo json_encode(["error" => "Failed to delete time slot", "sql_error" => $conn->error]);
}

$conn->close();
?>
