<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
function deleteProfilePicture($userId, $dbHost, $dbName, $dbUser, $dbPass) {
    try {
        $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8", $dbUser, $dbPass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $stmt = $pdo->prepare("DELETE FROM student_profile_pictures WHERE user_id = :user_id");
        $stmt->bindParam(':user_id', $userId);
        
        $result = $stmt->execute();
        $pdo = null; // Close connection
        return $result;
    } catch (PDOException $e) {
        error_log("Database error: " . $e->getMessage());
        return false;
    }
}
?>