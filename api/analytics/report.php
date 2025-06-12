<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type");

// Database configuration
$dbHost = 'localhost';
$dbName = 'final_careercoaching';
$dbUser = 'root';
$dbPass = '';

// Create database connection
try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(['success' => false, 'error' => "Database connection failed: " . $e->getMessage()]));
}

// Function to export data to CSV
function exportToCSV($data, $filename) {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="' . $filename . '.csv"');
    
    $output = fopen('php://output', 'w');
    
    // Write headers
    if (!empty($data)) {
        fputcsv($output, array_keys($data[0]));
    }
    
    // Write data
    foreach ($data as $row) {
        fputcsv($output, $row);
    }
    
    fclose($output);
    exit;
}

// Function to return data as JSON
function returnAsJson($data, $reportType) {
    header('Content-Type: application/json');
    echo json_encode([
        'success' => true,
        'report_type' => $reportType,
        'data' => $data,
        'generated_at' => date('Y-m-d H:i:s')
    ]);
    exit;
}

// Handle report request
$isPost = $_SERVER['REQUEST_METHOD'] === 'POST';
$reportType = $isPost ? ($_POST['report_type'] ?? null) : ($_GET['report_type'] ?? null);
$format = $isPost ? ($_POST['format'] ?? 'csv') : ($_GET['format'] ?? 'csv');

if (!$reportType) {
    die(json_encode(['success' => false, 'error' => 'Report type not specified']));
}

$filename = '';
$data = [];

try {
    switch ($reportType) {
        case 'course_engagement':
            $stmt = $pdo->query("SELECT * FROM vw_course_engagement");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $filename = 'course_engagement_report_' . date('Y-m-d');
            break;
            
        case 'department_engagement':
            $stmt = $pdo->query("SELECT * FROM vw_department_engagement");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $filename = 'department_engagement_report_' . date('Y-m-d');
            break;
            
        case 'gender_engagement':
            $stmt = $pdo->query("SELECT * FROM vw_gender_engagement");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $filename = 'gender_engagement_report_' . date('Y-m-d');
            break;
            
        case 'service_analytics':
            $stmt = $pdo->query("SELECT * FROM vw_service_analytics");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $filename = 'service_analytics_report_' . date('Y-m-d');
            break;
            
        case 'year_level_engagement':
            $stmt = $pdo->query("SELECT * FROM vw_year_level_engagement");
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $filename = 'year_level_engagement_report_' . date('Y-m-d');
            break;
            
        default:
            die(json_encode(['success' => false, 'error' => 'Invalid report type selected']));
    }
    
    if (empty($data)) {
        die(json_encode(['success' => false, 'error' => 'No data found for the selected report']));
    }
    
    if ($format === 'json') {
        returnAsJson($data, $reportType);
    } else {
        exportToCSV($data, $filename);
    }
} catch (PDOException $e) {
    die(json_encode(['success' => false, 'error' => "Error generating report: " . $e->getMessage()]));
}
?>