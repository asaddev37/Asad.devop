<?php
// 500 Error Page
http_response_code(500);
include '../includes/header.php';
?>
<div class="container mt-5"><h1>500 - Internal Server Error</h1></div>
<?php include '../includes/footer.php'; ?>
