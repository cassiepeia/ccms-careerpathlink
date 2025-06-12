<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
function updateProfilePicture($userId, $imagePath, $mimeType, $fileSize, $dbHost, $dbName, $dbUser, $dbPass) {
    try {
        $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8", $dbUser, $dbPass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $stmt = $pdo->prepare("UPDATE student_profile_pictures 
                              SET image_path = :image_path, 
                                  mime_type = :mime_type, 
                                  file_size = :file_size,
                                  uploaded_at = CURRENT_TIMESTAMP
                              WHERE user_id = :user_id");
        
        $stmt->bindParam(':user_id', $userId);
        $stmt->bindParam(':image_path', $imagePath);
        $stmt->bindParam(':mime_type', $mimeType);
        $stmt->bindParam(':file_size', $fileSize, PDO::PARAM_INT);
        
        $result = $stmt->execute();
        $pdo = null; // Close connection
        return $result;
    } catch (PDOException $e) {
        error_log("Database error: " . $e->getMessage());
        return false;
    }
}
?>