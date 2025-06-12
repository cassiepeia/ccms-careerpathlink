// update_user.php
<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: PUT');
header('Access-Control-Allow-Headers: Content-Type');

error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed", "details" => $conn->connect_error]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data["user_id"], $data["name"], $data["email"], $data["role"])) {
    $user_id = $conn->real_escape_string($data["user_id"]);
    $name = $conn->real_escape_string($data["name"]);
    $email = $conn->real_escape_string($data["email"]);
    $role = $conn->real_escape_string($data["role"]);
    $coach_role = isset($data["coach_role"]) ? $conn->real_escape_string($data["coach_role"]) : NULL;

    $sql = "UPDATE users SET name='$name', email='$email', role='$role', coach_role='$coach_role' WHERE user_id='$user_id'";

    if ($conn->query($sql)) {
        echo json_encode(["success" => "User updated successfully"]);
    } else {
        echo json_encode(["error" => "Failed to update user", "details" => $conn->error]);
    }
} else {
    echo json_encode(["error" => "Invalid input"]);
}

$conn->close();
?>