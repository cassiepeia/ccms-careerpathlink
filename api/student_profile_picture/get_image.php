<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Expose-Headers: Content-Disposition");

// Validate the image parameter
if (!isset($_GET['image']) || empty($_GET['image'])) {
    header("HTTP/1.0 400 Bad Request");
    die("Image parameter is required");
}

// Sanitize the input to prevent directory traversal
$imageName = basename($_GET['image']);
$imagePath = $_SERVER['DOCUMENT_ROOT'] . '/final_career_coaching/assets/uploaded/' . $imageName;

// Check if file exists
if (!file_exists($imagePath)) {
    error_log("Image not found: " . $imagePath);
    header("HTTP/1.0 404 Not Found");
    die("Image not found");
}

// Set appropriate content-type header based on file extension
$extension = strtolower(pathinfo($imagePath, PATHINFO_EXTENSION));
switch ($extension) {
    case 'jpg':
    case 'jpeg':
        header('Content-Type: image/jpeg');
        break;
    case 'png':
        header('Content-Type: image/png');
        break;
    case 'gif':
        header('Content-Type: image/gif');
        break;
    default:
        header('Content-Type: application/octet-stream');
}

// Set caching headers (1 day)
header('Cache-Control: public, max-age=86400');
header('Expires: ' . gmdate('D, d M Y H:i:s', time() + 86400) . ' GMT');

// Output the image
readfile($imagePath);
?>