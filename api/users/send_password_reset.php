<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

// Connect to database
$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed"]);
    exit;
}

// Read raw input
$rawData = file_get_contents("php://input");
error_log("Received JSON: " . $rawData);

$data = json_decode($rawData, true);

if (!empty($data) && isset($data["user_id"])) {
    $user_id = $conn->real_escape_string($data["user_id"]);
    
    // Get user email from database
    $query = "SELECT email FROM users WHERE user_id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        $email = $user['email'];
        
        // Generate a temporary password (or instruct user to create a new one)
        $tempPassword = bin2hex(random_bytes(8)); // 16-character random password
        
        // Hash the new password
        $hashedPassword = password_hash($tempPassword, PASSWORD_DEFAULT);
        
        // Update password in database
        $updateQuery = "UPDATE users SET password = ? WHERE user_id = ?";
        $updateStmt = $conn->prepare($updateQuery);
        $updateStmt->bind_param("ss", $hashedPassword, $user_id);
        $updateStmt->execute();
        
        // Send email with temporary password
        $subject = "Your Password Has Been Reset";
        $message = "Your password has been reset. Here's your new temporary password:\n\n";
        $message .= "Password: $tempPassword\n\n";
        $message .= "Please log in and change your password immediately for security reasons.\n";
        $message .= "If you didn't request this change, please contact support immediately.";
        $headers = "From: no-reply@yourdomain.com";
        
        if (mail($email, $subject, $message, $headers)) {
            echo json_encode(["success" => "Password reset email sent with new temporary password"]);
        } else {
            // Rollback password change if email fails
            $updateStmt = $conn->prepare("UPDATE users SET password = '' WHERE user_id = ?");
            $updateStmt->bind_param("s", $user_id);
            $updateStmt->execute();
            
            echo json_encode(["error" => "Failed to send email. Password not changed."]);
        }
    } else {
        echo json_encode(["error" => "User not found"]);
    }
} else {
    echo json_encode(["error" => "Invalid input"]);
}

$conn->close();
?>