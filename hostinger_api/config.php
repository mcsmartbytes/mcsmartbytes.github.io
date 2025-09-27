<?php
// Hostinger Database Configuration
$host = 'localhost'; // Usually localhost on Hostinger
$dbname = 'your_database_name'; // Your Hostinger database name
$username = 'your_db_username'; // Your database username
$password = 'your_db_password'; // Your database password
$api_key = 'your_secure_api_key'; // Generate a secure API key

// Create PDO connection
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

// CORS headers for Flutter web app
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Verify API key
function verifyApiKey() {
    global $api_key;
    
    $headers = getallheaders();
    $auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
    
    if (!$auth_header || !str_starts_with($auth_header, 'Bearer ')) {
        http_response_code(401);
        echo json_encode(['error' => 'Missing or invalid authorization']);
        exit;
    }
    
    $token = substr($auth_header, 7);
    if ($token !== $api_key) {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid API key']);
        exit;
    }
}
?>