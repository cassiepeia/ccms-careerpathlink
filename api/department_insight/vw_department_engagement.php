<?php
// Database configuration
define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', '');
define('DB_NAME', 'final_careercoaching');

// Create connection
$conn = new mysqli(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Set headers for API
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'error_log.txt');

// Handle GET request to fetch department engagement data
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        // First, get total engagement for normalization
        $totalQuery = "SELECT SUM(engagement_rate) AS total_engagement FROM vw_department_engagement";
        $totalResult = $conn->query($totalQuery);
        
        if (!$totalResult) {
            throw new Exception("Error calculating total engagement: " . $conn->error);
        }
        
        $totalRow = $totalResult->fetch_assoc();
        $totalEngagement = $totalRow['total_engagement'] ?: 1; // Avoid division by zero
        
        // Then get department data with normalized percentages
        $query = "SELECT 
                    d.department,
                    d.total_students,
                    d.active_students,
                    d.total_appointments,
                    d.completed_appointments,
                    d.cancelled_appointments,
                    d.pending_appointments,
                    d.engagement_rate,
                    d.completion_rate,
                    (SELECT sp.level 
                     FROM student_profiles sp
                     JOIN appointments a ON sp.student_name = a.student_name
                     WHERE sp.department = d.department
                     GROUP BY sp.level
                     ORDER BY COUNT(DISTINCT sp.user_id) DESC
                     LIMIT 1) AS most_active_year,
                    ROUND((d.engagement_rate / ?) * 100, 2) AS percentage_of_total
                  FROM vw_department_engagement d";
        
        $stmt = $conn->prepare($query);
        $stmt->bind_param("d", $totalEngagement);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if (!$result) {
            throw new Exception("Error executing query: " . $conn->error);
        }
        
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        
        // Return JSON response
        echo json_encode([
            'success' => true,
            'data' => $data,
            'message' => 'Department engagement data retrieved successfully',
            'total_engagement' => $totalEngagement
        ]);
        
    } catch (Exception $e) {
        // Return error response
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => $e->getMessage()
        ]);
    }
} else {
    // Return method not allowed
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
}

// Close connection
$conn->close();
?>