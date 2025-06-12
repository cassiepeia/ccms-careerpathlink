<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE, OPTIONS");
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

if ($_SERVER["REQUEST_METHOD"] === "DELETE") {
    $rawData = file_get_contents("php://input");
    $data = json_decode($rawData, true);

    if (!isset($data["id"])) {
        echo json_encode(["error" => "Missing coach profile ID"]);
        exit();
    }

    $id = $conn->real_escape_string($data["id"]);

    // Check if profile exists
    $check_sql = "SELECT id FROM coach_profiles WHERE id = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("i", $id);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows === 0) {
        echo json_encode([
            "error" => true,
            "message" => "Coach profile not found"
        ]);
        $check_stmt->close();
        $conn->close();
        exit();
    }
    $check_stmt->close();

    // Delete the profile
    $delete_sql = "DELETE FROM coach_profiles WHERE id = ?";
    $delete_stmt = $conn->prepare($delete_sql);
    $delete_stmt->bind_param("i", $id);

    if ($delete_stmt->execute()) {
        echo json_encode([
            "success" => true,
            "message" => "Coach profile deleted successfully"
        ]);
    } else {
        echo json_encode([
            "error" => true,
            "message" => "Error deleting coach profile: " . $delete_stmt->error
        ]);
    }

    $delete_stmt->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>