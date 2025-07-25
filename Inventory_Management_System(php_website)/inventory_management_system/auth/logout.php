<?php
// Logout script
session_start();
if (isset($_SESSION['user_id'])) {
    include_once '../includes/config.php';
    include_once '../includes/functions.php';
    logActivity($_SESSION['user_id'], 'Logout', 'User logged out');
}
session_destroy();
header('Location: /php_projects/final_project1/inventory_management_system/index.php');
exit;
?>
