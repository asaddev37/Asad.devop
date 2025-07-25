<?php
require_once __DIR__ . '/../../includes/config.php';
$actions = [];
$res = $conn->query('SELECT DISTINCT action FROM AuditLogs ORDER BY action');
while($row = $res->fetch_assoc()) {
    $actions[] = $row['action'];
}
header('Content-Type: application/json');
echo json_encode($actions);
