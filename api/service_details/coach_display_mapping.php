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
    
    if ($action === 'get_analytics') {
        // Get service analytics with proper counting
        $analyticsSql = "SELECT 
                            IFNULL(service_type, 'Unknown') AS service_type,
                            COUNT(id) AS total_appointments,
                            SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_appointments,
                            SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_appointments,
                            SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending_appointments,
                            ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / 
                                  NULLIF(COUNT(id), 0), 2) AS completion_rate
                          FROM appointments
                          GROUP BY service_type";
        
        // Get totals across all services
        $totalsSql = "SELECT 
                          COUNT(id) AS total_all_appointments,
                          SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS total_completed,
                          SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS total_cancelled,
                          SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS total_pending,
                          ROUND(SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / 
                                NULLIF(COUNT(id), 0), 2) AS total_completion_rate
                       FROM appointments";
        
        $result = $conn->query($analyticsSql);
        $totalsResult = $conn->query($totalsSql);
        
        if ($result && $totalsResult) {
            $analytics = [];
            while($row = $result->fetch_assoc()) {
                $analytics[] = $row;
            }
            
            $totals = $totalsResult->fetch_assoc();
            
            // Ensure all service types are represented even if count is 0
            $allServices = ['Career Coaching', 'Mock Interview', 'CV Review'];
            $finalAnalytics = [];
            
            foreach ($allServices as $service) {
                $found = false;
                foreach ($analytics as $item) {
                    if ($item['service_type'] === $service) {
                        $finalAnalytics[] = $item;
                        $found = true;
                        break;
                    }
                }
                if (!$found) {
                    $finalAnalytics[] = [
                        'service_type' => $service,
                        'total_appointments' => 0,
                        'completed_appointments' => 0,
                        'cancelled_appointments' => 0,
                        'pending_appointments' => 0,
                        'completion_rate' => 0.0
                    ];
                }
            }
            
            echo json_encode([
                "success" => true,
                "data" => [
                    "services" => $finalAnalytics,
                    "totals" => $totals
                ]
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "error" => $conn->error
            ]);
        }
    } else {
        // Original coach fetching functionality
        $sql = "SELECT id, coach_name, user_id, profile_id FROM coaches";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $coaches = [];
            while($row = $result->fetch_assoc()) {
                $coaches[] = $row;
            }
            echo json_encode([
                "success" => true,
                "data" => $coaches
            ]);
        } else {
            echo json_encode([
                "message" => "No coaches found",
                "data" => []
            ]);
        }
    }
} 
elseif ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Original coach by ID functionality
    $rawData = file_get_contents("php://input");
    $data = json_decode($rawData, true);

    if (!isset($data["coach_id"])) {
        echo json_encode(["error" => "Missing coach_id"]);
        exit();
    }

    $coach_id = $conn->real_escape_string($data["coach_id"]);
    
    $sql = "SELECT id, coach_name, user_id, profile_id FROM coaches WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $coach_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $coach = $result->fetch_assoc();
        echo json_encode([
            "success" => true,
            "data" => $coach
        ]);
    } else {
        echo json_encode([
            "message" => "Coach not found",
            "data" => []
        ]);
    }

    $stmt->close();
} else {
    echo json_encode(["error" => "Invalid request method"]);
}

$conn->close();
?>