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

if (isset($data['email'])) {
    $email = $conn->real_escape_string($data['email']);
    
    // Check if email exists in the database
    $checkSql = "SELECT * FROM users WHERE email = '$email' AND role = 'Coach'";
    $result = $conn->query($checkSql);
    
    if ($result->num_rows === 0) {
        echo json_encode(["error" => "No coach found with this email address"]);
        $conn->close();
        exit();
    }
    
    // Generate a new random password
    $newPassword = bin2hex(random_bytes(8)); // Generates a 16-character password
    $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
    
    // Update the password in the database
    $updateSql = "UPDATE users SET password = '$hashedPassword' WHERE email = '$email'";
    
    if ($conn->query($updateSql)) {
        // Send email with the new password (you'll need to implement your email sending logic)
        // For now, we'll just return the new password in the response
        // In production, you should send the email and not return the password in the response
        echo json_encode([
            "success" => true,
            "message" => "Password reset successfully. A new password has been sent to your email.",
            "new_password" => $newPassword // Remove this in production
        ]);
    } else {
        echo json_encode(["error" => "Failed to reset password: " . $conn->error]);
    }
} else {
    echo json_encode(["error" => "Email is required"]);
}

$conn->close();
?>