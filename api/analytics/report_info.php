<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$reportTypes = [
    'course_engagement' => [
        'report_type' => 'course_engagement',
        'display_name' => 'Course Engagement Report',
        'description' => 'Shows engagement metrics by academic course'
    ],
    'department_engagement' => [
        'report_type' => 'department_engagement',
        'display_name' => 'Department Engagement Report',
        'description' => 'Shows engagement metrics by department'
    ],
    'gender_engagement' => [
        'report_type' => 'gender_engagement',
        'display_name' => 'Gender Engagement Report',
        'description' => 'Shows engagement metrics by gender'
    ],
    'service_analytics' => [
        'report_type' => 'service_analytics',
        'display_name' => 'Service Analytics Report',
        'description' => 'Shows service usage and completion rates'
    ],
    'year_level_engagement' => [
        'report_type' => 'year_level_engagement',
        'display_name' => 'Year Level Engagement Report',
        'description' => 'Shows engagement metrics by year level'
    ]
];

$requestedType = $_GET['report_type'] ?? null;

if ($requestedType) {
    if (isset($reportTypes[$requestedType])) {
        echo json_encode([
            'success' => true,
            'data' => $reportTypes[$requestedType]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid report type'
        ]);
    }
} else {
    // Return all report types if none specified
    echo json_encode([
        'success' => true,
        'data' => array_values($reportTypes)
    ]);
}
?>