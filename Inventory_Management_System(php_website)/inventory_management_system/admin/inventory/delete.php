<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';

$id = $_GET['id'] ?? null;
if ($id) {
    $stmt = $conn->prepare('DELETE FROM Inventory WHERE id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $stmt->close();
    include_once '../../includes/functions.php';
    logActivity($_SESSION['user_id'], 'Delete Inventory', 'Deleted inventory item ID: ' . $id);
}
header('Location: index.php');
exit;
