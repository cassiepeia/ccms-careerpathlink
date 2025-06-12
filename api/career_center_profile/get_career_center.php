<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

$user_id = isset($_GET['user_id']) ? $conn->real_escape_string($_GET['user_id']) : null;

if ($user_id) {
    $sql = "SELECT * FROM career_center_profile WHERE user_id = '$user_id'";
} else {
    $sql = "SELECT * FROM career_center_profile";
}

$result = $conn->query($sql);

if ($result) {
    $profiles = [];
    while ($row = $result->fetch_assoc()) {
        $profiles[] = $row;
    }
    echo json_encode($profiles);
} else {
    echo json_encode(["error" => "Error fetching profiles: " . $conn->error]);
}

$conn->close();
?>