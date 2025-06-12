<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'error' => 'Database connection failed: ' . $conn->connect_error
    ]));
}

try {
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);
    
    if (!isset($data['user_id'])) {
        die(json_encode([
            'success' => false,
            'error' => 'User ID is required'
        ]));
    }

    $user_id = $data['user_id'];
    error_log("Received user ID: " . $user_id);

    // Step 1: Get internal user ID from users table
    $stmt = $conn->prepare("SELECT id FROM users WHERE user_id = ?");
    $stmt->bind_param("s", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        die(json_encode([
            'success' => false,
            'error' => 'User not found'
        ]));
    }
    
    $row = $result->fetch_assoc();
    $internal_user_id = $row['id'];
    $stmt->close();
    error_log("Internal user ID: " . $internal_user_id);

    // Step 2: Get coach ID from coaches table
    $stmt = $conn->prepare("SELECT id FROM coaches WHERE user_id = ?");
    $stmt->bind_param("i", $internal_user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        die(json_encode([
            'success' => false,
            'error' => 'Coach not found for this user'
        ]));
    }
    
    $row = $result->fetch_assoc();
    $coach_id = $row['id'];
    $stmt->close();
    error_log("Coach ID: " . $coach_id);

    echo json_encode([
        'success' => true,
        'coach_id' => $coach_id,
        'user_id' => $user_id,
        'internal_user_id' => $internal_user_id
    ]);

} catch (Exception $e) {
    error_log("Error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
} finally {
    $conn->close();
}
?>