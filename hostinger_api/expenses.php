<?php
require_once 'config.php';

verifyApiKey();

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $stmt = $pdo->query("SELECT * FROM expenses ORDER BY date DESC");
        $expenses = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode($expenses);
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to fetch expenses: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>