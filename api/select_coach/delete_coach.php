<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE");

$servername = "localhost";
$username = "root"; // Default for Laragon
$password = ""; // Default for Laragon
$dbname = "final_careercoaching"; // Change this to your actual DB name

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed"]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['id'])) {
    $id = $data['id'];

    $sql = "DELETE FROM coaches WHERE id = $id";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["message" => "Coach deleted successfully"]);
    } else {
        echo json_encode(["error" => "Failed to delete coach"]);
    }
} else {
    echo json_encode(["error" => "Missing coach ID"]);
}

$conn->close();
?>
