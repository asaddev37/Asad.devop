<?php
include '../includes/config.php';
if ($conn && !$conn->connect_error) {
    echo '<div style="color:green;font-weight:bold;">MySQL connection successful!</div>';
} else {
    echo '<div style="color:red;font-weight:bold;">MySQL connection failed: ' . htmlspecialchars($conn->connect_error) . '</div>';
}
?>
