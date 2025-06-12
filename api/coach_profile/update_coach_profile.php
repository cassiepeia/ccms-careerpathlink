<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, PUT, OPTIONS");
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
            "success" => false,
            "message" => "No coach profiles found"
        ]);
    }
    exit();
}

if ($_SERVER["REQUEST_METHOD"] === "PUT") {
    $rawData = file_get_contents("php://input");
    error_log("Raw input data: " . $rawData);
    $data = json_decode($rawData, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        echo json_encode(["error" => "Invalid JSON data: " . json_last_error_msg()]);
        exit();
    }

    if (!isset($data["userId"])) {
        echo json_encode(["error" => "Missing coach profile user ID"]);
        exit();
    }

    $userId = $conn->real_escape_string($data["userId"]);
    $updates = [];
    $params = [];
    $types = "";

    if (isset($data["coach_name"])) {
        $updates[] = "coach_name = ?";
        $params[] = $conn->real_escape_string($data["coach_name"]);
        $types .= "s";
    }

    if (isset($data["position"])) {
        $updates[] = "position = ?";
        $params[] = $conn->real_escape_string($data["position"]);
        $types .= "s";
    }

    if (isset($data["contact"])) {
        $updates[] = "contact = ?";
        $params[] = $conn->real_escape_string($data["contact"]);
        $types .= "s";
    }

    if (isset($data["email"])) {
        $updates[] = "email = ?";
        $params[] = $conn->real_escape_string($data["email"]);
        $types .= "s";
    }

    if (isset($data["address"])) {
        $updates[] = "address = ?";
        $params[] = $conn->real_escape_string($data["address"]);
        $types .= "s";
    }

    if (empty($updates)) {
        echo json_encode(["error" => "No fields to update"]);
        exit();
    }

    $sql = "UPDATE coach_profiles SET " . implode(", ", $updates) . " WHERE user_id = ?";
    $types .= "s";
    $params[] = $userId;

    $stmt = $conn->prepare($sql);
    if ($stmt === false) {
        echo json_encode(["error" => "Prepare failed: " . $conn->error]);
        exit();
    }

    $bindParams = [$types];
    foreach ($params as &$param) {
        $bindParams[] = &$param;
    }
    
    call_user_func_array([$stmt, 'bind_param'], $bindParams);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode([
                "success" => true,
                "message" => "Coach profile updated successfully",
                "affected_rows" => $stmt->affected_rows
            ]);
        } else {
            echo json_encode([
                "success" => true,
                "message" => "No changes made to coach profile",
                "affected_rows" => 0
            ]);
        }
    } else {
        echo json_encode([
            "error" => true,
            "message" => "Error updating coach profile: " . $stmt->error
        ]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>