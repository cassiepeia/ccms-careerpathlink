<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: *");
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
    // First get total active students across all courses
    $totalActiveQuery = "SELECT COUNT(DISTINCT sp.user_id) as total_active 
                         FROM student_profiles sp
                         JOIN appointments a ON sp.student_name = a.student_name";
    $totalActiveResult = $conn->query($totalActiveQuery);
    $totalActive = $totalActiveResult ? $totalActiveResult->fetch_assoc()['total_active'] : 0;

    // Then get course-specific data
    $sql = "SELECT 
                course,
                COUNT(DISTINCT sp.user_id) as total_students,
                COUNT(DISTINCT CASE WHEN a.id IS NOT NULL THEN sp.user_id END) as active_students,
                COUNT(a.id) as total_appointments,
                SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) as completed_appointments,
                SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled_appointments,
                SUM(CASE WHEN a.status = 'Pending' THEN 1 ELSE 0 END) as pending_appointments
            FROM student_profiles sp
            LEFT JOIN appointments a ON sp.student_name = a.student_name
            GROUP BY sp.course
            ORDER BY active_students DESC";

    $result = $conn->query($sql);

    if ($result) {
        $courses = [];
        while ($row = $result->fetch_assoc()) {
            $activeStudents = (int)($row['active_students'] ?? 0);
            $totalStudents = (int)($row['total_students'] ?? 0);
            $totalAppointments = (int)($row['total_appointments'] ?? 0);
            $completedAppointments = (int)($row['completed_appointments'] ?? 0);
            
            // Calculate engagement rate as percentage of total active students
            $engagementRate = $totalActive > 0 ? 
                round(($activeStudents / $totalActive) * 100, 2) : 0;
                
            // Completion rate remains per-course
            $completionRate = $totalAppointments > 0 ? 
                round(($completedAppointments / $totalAppointments) * 100, 2) : 0;

            $courses[] = [
                'course' => $row['course'] ?? 'Unknown',
                'total_students' => $totalStudents,
                'active_students' => $activeStudents,
                'total_appointments' => $totalAppointments,
                'completed_appointments' => $completedAppointments,
                'cancelled_appointments' => (int)($row['cancelled_appointments'] ?? 0),
                'pending_appointments' => (int)($row['pending_appointments'] ?? 0),
                'engagement_rate' => $engagementRate,
                'completion_rate' => $completionRate
            ];
        }

        echo json_encode([
            'success' => true,
            'data' => $courses,
            'count' => count($courses),
            'total_active_students' => $totalActive
        ]);
    } else {
        echo json_encode([
            'error' => true,
            'message' => 'Error fetching course engagement data: ' . $conn->error
        ]);
    }
} else {
    echo json_encode(["error" => "Invalid request method. Use GET to fetch course engagement data"]);
}

$conn->close();
?>