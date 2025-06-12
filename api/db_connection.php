<?php
$servername = "localhost";
$username = "final_careercoaching";
$password = "";
$dbname = "final_careercoaching";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
