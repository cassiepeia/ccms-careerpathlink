<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
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

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    // Get all year level engagement data
    $sql = "SELECT * FROM vw_year_level_engagement";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $engagementData = [];
        $totalStudents = 0;
        $totalActive = 0;
        $totalAppointments = 0;
        
        // First pass to calculate totals
        while($row = $result->fetch_assoc()) {
            $totalStudents += $row['total_students'];
            $totalActive += $row['active_students'];
            $totalAppointments += $row['total_appointments'];
        }
        
        // Reset pointer to loop again
        $result->data_seek(0);
        
        // Second pass to calculate relative percentages
        while($row = $result->fetch_assoc()) {
            $row['student_distribution'] = round(($row['total_students'] / $totalStudents) * 100, 2);
            $row['engagement_rate'] = round(($row['active_students'] / $totalActive) * 100, 2);
            $row['appointment_distribution'] = round(($row['total_appointments'] / $totalAppointments) * 100, 2);
            $engagementData[] = $row;
        }
        
        // Sort by engagement rate (highest first)
        usort($engagementData, function($a, $b) {
            return $b['engagement_rate'] <=> $a['engagement_rate'];
        });
        
        echo json_encode([
            "success" => true,
            "data" => $engagementData
        ]);
    } else {
        echo json_encode([
            "message" => "No year level engagement data found",
            "data" => []
        ]);
    }
} elseif ($_SERVER["REQUEST_METHOD"] === "POST") {
    $rawData = file_get_contents("php://input");
    $data = json_decode($rawData, true);

    if (!isset($data["year_level"])) {
        echo json_encode(["error" => "Missing year_level"]);
        exit();
    }

    $year_level = $conn->real_escape_string($data["year_level"]);
    
    // Get engagement data for a specific year level
    $sql = "SELECT * FROM vw_year_level_engagement WHERE year_level = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $year_level);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // For single year level, we'll use the original values
        $engagementData = [];
        while($row = $result->fetch_assoc()) {
            $engagementData[] = $row;
        }
        echo json_encode([
            "success" => true,
            "data" => $engagementData
        ]);
    } else {
        echo json_encode([
            "message" => "No engagement data found for this year level",
            "data" => []
        ]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>