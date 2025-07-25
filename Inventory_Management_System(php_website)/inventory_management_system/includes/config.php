<?php
// Database config
const DB_HOST = '127.0.0.1';
const DB_NAME = 'inventory_system';
const DB_USER = 'root';
const DB_PASS = 'ak37';
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
if ($conn->connect_error) die('Connection failed: ' . $conn->connect_error);
?>
