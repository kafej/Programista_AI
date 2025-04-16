<?php
// Database credentials (replace with your actual values)
$host = 'localhost';
$db   = 'vault';
$user = 'external';
$pass = 'Qwerty123';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $request_id = $_GET['request_id'];

    // Query the database for the answer
    $stmt = $pdo->prepare("SELECT answer FROM requests WHERE id = ? AND done = 'no'");
    $stmt->execute([$request_id]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result && isset($result['answer'])) {
        echo json_encode(['answer' => $result['answer']]);
    } else {
        echo json_encode(['answer' => null]); // Still no answer
    }

} catch (PDOException $e) {
    echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
}
?>