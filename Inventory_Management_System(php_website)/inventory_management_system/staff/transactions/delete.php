<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Staff') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/functions.php';

$id = intval($_GET['id'] ?? 0);
$user_id = $_SESSION['user_id'];

if ($id) {
    $stmt = $conn->prepare("DELETE FROM Transactions WHERE id = ? AND user_id = ?");
    $stmt->bind_param('ii', $id, $user_id);
    if ($stmt->execute()) {
        logActivity($user_id, 'Delete Transaction', 'Deleted transaction ID: ' . $id);
        header('Location: index.php?deleted=1');
        exit;
    } else {
        header('Location: index.php?deleted=0');
        exit;
    }
}
header('Location: index.php');
exit;
