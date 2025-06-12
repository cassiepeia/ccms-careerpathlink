<?php
// Database configuration
$dbHost = 'localhost';
$dbName = 'final_careercoaching';
$dbUser = 'root';
$dbPass = '';

// Include CRUD functions
require_once 'create_profile_picture.php';
require_once 'update_profile_picture.php';
require_once 'read_profile_picture.php';
require_once 'delete_profile_picture.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['profile_picture'])) {
    $userId = $_POST['user_id'];
    $file = $_FILES['profile_picture'];
    
    // Validate file type
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (!in_array($file['type'], $allowedTypes)) {
        die("Invalid file type. Only JPG, PNG, and GIF are allowed.");
    }
    
    // Create uploads directory if it doesn't exist
    $uploadDir = 'uploads/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }
    
    // Generate unique filename
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = $userId . '_' . time() . '.' . $extension;
    $destination = $uploadDir . $filename;
    
    // Move uploaded file
    if (move_uploaded_file($file['tmp_name'], $destination)) {
        // Check if user already has a profile picture
        $existingPicture = getProfilePictureByUserId($userId, $dbHost, $dbName, $dbUser, $dbPass);
        
        if ($existingPicture) {
            // Update existing record
            if (updateProfilePicture($userId, $destination, $file['type'], $file['size'], $dbHost, $dbName, $dbUser, $dbPass)) {
                // Delete the old file
                if (file_exists($existingPicture['image_path'])) {
                    unlink($existingPicture['image_path']);
                }
                echo "Profile picture updated successfully!";
            } else {
                // Clean up the uploaded file if database operation failed
                unlink($destination);
                echo "Failed to update profile picture in database.";
            }
        } else {
            // Create new record
            if (createProfilePicture($userId, $destination, $file['type'], $file['size'], $dbHost, $dbName, $dbUser, $dbPass)) {
                echo "Profile picture uploaded successfully!";
            } else {
                // Clean up the uploaded file if database operation failed
                unlink($destination);
                echo "Failed to save profile picture to database.";
            }
        }
    } else {
        echo "Failed to upload file.";
    }
}
?>

<form action="upload_handler.php" method="post" enctype="multipart/form-data">
    <input type="text" name="user_id" placeholder="User ID" required>
    <input type="file" name="profile_picture" accept="image/jpeg,image/png,image/gif" required>
    <button type="submit">Upload Profile Picture</button>
</form>