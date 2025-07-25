<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/functions.php';

$id = $_GET['id'] ?? null;
if ($id) {
    $stmt = $conn->prepare('DELETE FROM Suppliers WHERE id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $stmt->close();
    logActivity($_SESSION['user_id'], 'Delete Supplier', 'Deleted supplier ID: ' . $id);
}
header('Location: index.php');
exit;
