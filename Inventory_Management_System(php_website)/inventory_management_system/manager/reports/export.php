<?php
session_start();
if (!isset($_SESSION['user_id']) || strtolower($_SESSION['role']) !== 'manager') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/functions.php';

header('Content-Type: text/csv');
header('Content-Disposition: attachment; filename="manager_report_' . date('Ymd_His') . '.csv"');

$output = fopen('php://output', 'w');
fputcsv($output, ['ID', 'Item', 'Type', 'Quantity', 'Date', 'Description', 'Performed By']);

$sql = "SELECT t.id, i.name AS item_name, t.type, t.quantity, t.transaction_date, t.description, u.username AS performed_by FROM Transactions t JOIN Inventory i ON t.item_id = i.id JOIN Users u ON t.user_id = u.id ORDER BY t.transaction_date DESC";
$result = $conn->query($sql);
if ($result) {
    while ($row = $result->fetch_assoc()) {
        fputcsv($output, [$row['id'], $row['item_name'], $row['type'], $row['quantity'], $row['transaction_date'], $row['description'], $row['performed_by']]);
    }
}
fclose($output);
logActivity($_SESSION['user_id'], 'Export Report', 'Manager exported transaction report as CSV.');
exit;
?>
