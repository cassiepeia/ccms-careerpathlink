<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

error_reporting(E_ALL);
ini_set('display_errors', 1);

$servername = "localhost";
$username = "root";
$password = "";
$database = "final_careercoaching";

$conn = new mysqli($servername, $username, $password, $database);

if ($conn->connect_error) {
    echo json_encode(["error" => "Database Connection Failed: " . $conn->connect_error]);
    exit();
}

if ($_SERVER["REQUEST_METHOD"] === "GET") {
    $action = $_GET['action'] ?? '';
    
    if ($action === 'get_gender_analytics') {
        $sql = "SELECT 
                    gender,
                    total_students,
                    active_students,
                    total_appointments,
                    completed_appointments,
                    cancelled_appointments,
                    pending_appointments,
                    engagement_rate,
                    completion_rate
                FROM vw_gender_engagement";
        
        $result = $conn->query($sql);
        $dbData = [];
        
        if ($result) {
            while($row = $result->fetch_assoc()) {
                $dbData[] = $row;
            }
        }
        
        $totalStudents = 0;
        foreach ($dbData as $item) {
            $totalStudents += $item['total_students'];
        }

        $genders = ['Male', 'Female'];
        $responseData = [];
        
        foreach ($genders as $gender) {
            $found = false;
            foreach ($dbData as $item) {
                if ($item['gender'] === $gender) {
                    $percentageDistribution = ($totalStudents > 0) 
                        ? ($item['total_students'] / $totalStudents * 100) 
                        : 0;

                    $responseData[] = [
                        'gender' => $gender,
                        'total_students' => (int)$item['total_students'],
                        'active_students' => (int)$item['active_students'],
                        'total_appointments' => (int)$item['total_appointments'],
                        'completed_appointments' => (int)$item['completed_appointments'],
                        'cancelled_appointments' => (int)$item['cancelled_appointments'],
                        'pending_appointments' => (int)$item['pending_appointments'],
                        'engagement_rate' => number_format((float)$item['engagement_rate'], 2) . '%',
                        'completion_rate' => number_format((float)$item['completion_rate'], 2) . '%',
                        'percentage_distribution' => number_format($percentageDistribution, 2)
                    ];
                    $found = true;
                    break;
                }
            }
            
            if (!$found) {
                $responseData[] = [
                    'gender' => $gender,
                    'total_students' => 0,
                    'active_students' => 0,
                    'total_appointments' => 0,
                    'completed_appointments' => 0,
                    'cancelled_appointments' => 0,
                    'pending_appointments' => 0,
                    'engagement_rate' => '0.00%',
                    'completion_rate' => '0.00%',
                    'percentage_distribution' => '0.00'
                ];
            }
        }
        
        echo json_encode([
            "success" => true,
            "data" => $responseData
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "error" => "Invalid action"
        ]);
    }
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>