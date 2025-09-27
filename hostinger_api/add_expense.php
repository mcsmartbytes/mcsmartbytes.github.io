<?php
require_once 'config.php';

verifyApiKey();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid JSON input']);
            exit;
        }
        
        $required_fields = ['id', 'description', 'category', 'amount', 'date'];
        foreach ($required_fields as $field) {
            if (!isset($input[$field]) || empty($input[$field])) {
                http_response_code(400);
                echo json_encode(['error' => "Missing required field: $field"]);
                exit;
            }
        }
        
        $stmt = $pdo->prepare("INSERT INTO expenses (id, description, category, amount, date, status, notes, created_at) 
                               VALUES (:id, :description, :category, :amount, :date, :status, :notes, NOW())");
        
        $result = $stmt->execute([
            ':id' => $input['id'],
            ':description' => $input['description'],
            ':category' => $input['category'],
            ':amount' => floatval($input['amount']),
            ':date' => $input['date'],
            ':status' => isset($input['status']) ? $input['status'] : 'pending',
            ':notes' => isset($input['notes']) ? $input['notes'] : null
        ]);
        
        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Expense added successfully']);
        } else {
            throw new Exception('Failed to insert expense');
        }
        
    } catch(PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    } catch(Exception $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>