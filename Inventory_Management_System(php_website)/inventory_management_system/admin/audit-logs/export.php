<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';

header('Content-Type: text/csv');
header('Content-Disposition: attachment; filename="audit_logs_' . date('Ymd_His') . '.csv"');

$output = fopen('php://output', 'w');
fputcsv($output, ['ID', 'User', 'Action', 'Timestamp', 'Details']);

$sql = "SELECT AuditLogs.id, Users.username, AuditLogs.action, AuditLogs.timestamp, AuditLogs.details FROM AuditLogs JOIN Users ON AuditLogs.user_id = Users.id ORDER BY AuditLogs.timestamp DESC";
$result = $conn->query($sql);
if ($result) {
    while ($log = $result->fetch_assoc()) {
        fputcsv($output, [$log['id'], $log['username'], $log['action'], $log['timestamp'], $log['details']]);
    }
}
fclose($output);
exit;
