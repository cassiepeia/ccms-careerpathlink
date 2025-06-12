<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
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

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    // Check if coach_id is provided
    if (!isset($_GET['coach_id'])) {
        echo json_encode([
            "error" => true,
            "message" => "Coach ID is required"
        ]);
        exit();
    }

    $coach_id = $conn->real_escape_string($_GET['coach_id']);

    // Query directly from appointments table
    $sql = "SELECT * FROM appointments 
            WHERE status = 'Completed' AND coach_id = ?
            ORDER BY date_requested DESC, time_requested DESC";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $coach_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $appointments = [];
        while($row = $result->fetch_assoc()) {
            $appointments[] = $row;
        }
        echo json_encode([
            "success" => true,
            "data" => $appointments
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "No completed sessions found for this coach",
            "data" => []
        ]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>