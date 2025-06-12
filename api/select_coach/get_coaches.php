<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

try {
    // Since we removed coach_role, we'll just select id and coach_name
    $sql = "SELECT id, coach_name FROM coaches";
    $result = $conn->query($sql);

    if (!$result) {
        throw new Exception("Query failed: " . $conn->error);
    }

    $coaches = [];

    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            // Add a default role since we removed the column
            $row['coach_role'] = 'Career Advisor';
            $row['image_url'] = ''; // Add default image URL
            $coaches[] = $row;
        }
    }

    echo json_encode($coaches);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["error" => $e->getMessage()]);
} finally {
    $conn->close();
}
?>