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

if (!empty($data) && isset($data["user_id"], $data["name"], $data["email"], $data["password"], $data["role"])) {
    // Disable triggers temporarily
    $conn->query("SET @DISABLE_TRIGGERS = TRUE;");
    
    // Clean and format the user ID
    $rawUserId = trim($data["user_id"]);
    $formattedUserId = preg_replace('/[^0-9]/', '', $rawUserId);
    if (strlen($formattedUserId) > 2) {
        $formattedUserId = substr($formattedUserId, 0, 2) . '-' . substr($formattedUserId, 2);
    }
    // Changed from 7 to 8 to allow 2 digits + hyphen + 5 digits
    if (strlen($formattedUserId) > 8) {
        $formattedUserId = substr($formattedUserId, 0, 8);
    }
    
    $user_id = $conn->real_escape_string($formattedUserId);
    $name = $conn->real_escape_string(trim($data["name"]));
    $email = $conn->real_escape_string(trim($data["email"]));
    $password = password_hash(trim($data["password"]), PASSWORD_DEFAULT);
    $role = $conn->real_escape_string(trim($data["role"]));
    
    // Additional fields for different roles
    $department = isset($data["department"]) ? $conn->real_escape_string(trim($data["department"])) : null;
    $course = isset($data["course"]) ? $conn->real_escape_string(trim($data["course"])) : null;
    $year_level = isset($data["year_level"]) ? $conn->real_escape_string(trim($data["year_level"])) : null;
    $address = isset($data["address"]) ? $conn->real_escape_string(trim($data["address"])) : null;
    $contact = isset($data["contact"]) ? $conn->real_escape_string(trim($data["contact"])) : null;
    $gender = isset($data["gender"]) ? $conn->real_escape_string(trim($data["gender"])) : null;

    // Check if user_id already exists
    $checkUserIdQuery = "SELECT user_id FROM users WHERE user_id = ?";
    $checkUserIdStmt = $conn->prepare($checkUserIdQuery);
    $checkUserIdStmt->bind_param("s", $user_id);
    $checkUserIdStmt->execute();
    $checkUserIdStmt->store_result();

    if ($checkUserIdStmt->num_rows > 0) {
        $checkUserIdStmt->close();
        echo json_encode(["error" => "User ID already exists"]);
        exit;
    }
    $checkUserIdStmt->close();

    // Check if email already exists
    $checkEmailQuery = "SELECT email FROM users WHERE email = ?";
    $checkEmailStmt = $conn->prepare($checkEmailQuery);
    $checkEmailStmt->bind_param("s", $email);
    $checkEmailStmt->execute();
    $checkEmailStmt->store_result();

    if ($checkEmailStmt->num_rows > 0) {
        $checkEmailStmt->close();
        echo json_encode(["error" => "Email already exists"]);
        exit;
    }
    $checkEmailStmt->close();

    // Start transaction
    $conn->begin_transaction();

    try {
        // Insert new user into users table
        $sql = "INSERT INTO users (user_id, name, email, password, role) VALUES (?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("sssss", $user_id, $name, $email, $password, $role);
        
        if (!$stmt->execute()) {
            throw new Exception("Failed to create user: " . $stmt->error);
        }
        
        $new_user_id = $stmt->insert_id;
        $stmt->close();

        // Insert into role-specific tables
        if ($role === "Student") {
            $studentSql = "INSERT INTO student_profiles (
                user_id, student_name, department, course, level, 
                address, contact, email, gender
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            $studentStmt = $conn->prepare($studentSql);
            $studentStmt->bind_param(
                "sssssssss", 
                $user_id, $name, $department, $course, $year_level,
                $address, $contact, $email, $gender
            );
            
            if (!$studentStmt->execute()) {
                throw new Exception("Failed to create student profile: " . $studentStmt->error);
            }
            $studentStmt->close();
            
        } elseif ($role === "Workforce Development Trainer") {
            // First insert into coach_profiles
            $coachProfileSql = "INSERT INTO coach_profiles (
                user_id, coach_name, email, address, contact
            ) VALUES (?, ?, ?, ?, ?)";
            
            $coachProfileStmt = $conn->prepare($coachProfileSql);
            $coachProfileStmt->bind_param(
                "sssss", 
                $user_id, $name, $email, $address, $contact
            );
            
            if (!$coachProfileStmt->execute()) {
                throw new Exception("Failed to create coach profile: " . $coachProfileStmt->error);
            }
            
            $profile_id = $coachProfileStmt->insert_id;
            $coachProfileStmt->close();
            
            // Then insert into coaches table
            $coachSql = "INSERT INTO coaches (coach_name, user_id, profile_id) VALUES (?, ?, ?)";
            $coachStmt = $conn->prepare($coachSql);
            $coachStmt->bind_param("sii", $name, $new_user_id, $profile_id);
            
            if (!$coachStmt->execute()) {
                throw new Exception("Failed to create coach record: " . $coachStmt->error);
            }
            $coachStmt->close();
            
        } elseif ($role === "Career Center Director") {
            $directorSql = "INSERT INTO career_center_profile (
                user_id, name, email, address, contact
            ) VALUES (?, ?, ?, ?, ?)";
            
            $directorStmt = $conn->prepare($directorSql);
            $directorStmt->bind_param(
                "sssss", 
                $user_id, $name, $email, $address, $contact
            );
            
            if (!$directorStmt->execute()) {
                throw new Exception("Failed to create director profile: " . $directorStmt->error);
            }
            $directorStmt->close();
        }

        $conn->commit();
        // Re-enable triggers
        $conn->query("SET @DISABLE_TRIGGERS = NULL;");
        echo json_encode(["success" => "User created successfully"]);
        
    } catch (Exception $e) {
        $conn->rollback();
        // Re-enable triggers even if there's an error
        $conn->query("SET @DISABLE_TRIGGERS = NULL;");
        echo json_encode(["error" => $e->getMessage()]);
    }
    
} else {
    echo json_encode(["error" => "Invalid input"]);
}

$conn->close();
?>