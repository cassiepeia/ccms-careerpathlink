<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["error" => "Database connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email'])) {
    echo json_encode(["error" => "Email is required"]);
    $conn->close();
    exit();
}

$email = $conn->real_escape_string($data['email']);

// First check if email exists at all
$email_check_sql = "SELECT * FROM users WHERE email = '$email'";
$email_check_result = $conn->query($email_check_sql);

if ($email_check_result->num_rows === 0) {
    echo json_encode(["error" => "No user found with this email"]);
    $conn->close();
    exit();
}

// Then check if it's a Career Center Director user
$role_check_sql = "SELECT * FROM users WHERE email = '$email' AND role = 'Career Center Director'";
$role_check_result = $conn->query($role_check_sql);

if ($role_check_result->num_rows === 0) {
    echo json_encode(["error" => "This email is not registered as a Career Center Director account"]);
    $conn->close();
    exit();
}

// Generate a new random password
$new_password = bin2hex(random_bytes(8)); // Generates a 16-character password
$hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

// Update the password in the database
$update_sql = "UPDATE users SET password = '$hashed_password' WHERE email = '$email'";

if ($conn->query($update_sql)) {
    echo json_encode([
        "success" => true,
        "message" => "Password reset successful. A new password has been sent to your email.",
        // Remove this in production - only for testing
        "new_password" => $new_password
    ]);
} else {
    echo json_encode(["error" => "Failed to reset password: " . $conn->error]);
}

$conn->close();
?>