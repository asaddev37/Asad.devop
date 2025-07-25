<?php
// Shared functions: logActivity, checkRole, etc.
function logActivity($user_id, $action, $details = '') {
    global $conn;
    $stmt = $conn->prepare('INSERT INTO AuditLogs (user_id, action, details) VALUES (?, ?, ?)');
    $stmt->bind_param('iss', $user_id, $action, $details);
    $stmt->execute();
    $stmt->close();
}
function checkRole($requiredRole) {
    session_start();
    if (!isset($_SESSION['role']) || $_SESSION['role'] !== $requiredRole) {
        header('Location: /auth/login.php');
        exit();
    }
}
?>
