<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, GET, POST, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
error_reporting(E_ALL);
error_log("Received data: " . print_r($data, true));
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

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    if (isset($_GET['id'])) {
        $id = $conn->real_escape_string($_GET['id']);
        $sql = "SELECT * FROM coach_profiles WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            $coachData = $result->fetch_assoc();
            echo json_encode([
                "success" => true,
                "data" => $coachData // This already includes user_id from your table
            ]);
        } else {
            echo json_encode([
                "error" => true,
                "message" => "Coach profile not found"
            ]);
        }
        $stmt->close();
    } else {
        $sql = "SELECT * FROM coach_profiles";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $coaches = [];
            while($row = $result->fetch_assoc()) {
                $coaches[] = $row;
            }
            echo json_encode([
                "success" => true,
                "data" => $coaches
            ]);
        } else {
            echo json_encode([
                "message" => "No coach profiles found",
                "data" => []
            ]);
        }
    }
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>