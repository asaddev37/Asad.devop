<?php
// Common header with Bootstrap, jQuery, DataTables CDN
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management System</title>
    <link rel="stylesheet" href="/assets/css/styles.css">
    <link rel="stylesheet" href="/assets/css/global-theme.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.4/css/jquery.dataTables.min.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="/assets/js/scripts.js"></script>
    <style>
      body {
        min-height: 100vh;
        background: linear-gradient(135deg, #2b5876 0%, #4e4376 100%) fixed !important;
        font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
        color: #fff;
      }
    </style>
</head>
<body style="background: linear-gradient(135deg, #2b5876 0%, #4e4376 100%) fixed !important; color: #fff;">
<?php if (isset($show_dashboard_header) && $show_dashboard_header): ?>
  <div class="neon-header-bar py-4 px-3" style="background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%) !important; color: #23243a; box-shadow: 0 2px 24px #00fff044, 0 1.5px 0 #ff61a6; border-bottom-left-radius: 18px; border-bottom-right-radius: 18px; margin-bottom: 0.5rem;">
    <h2 class="mb-0" style="font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-weight:bold; letter-spacing:1px; text-shadow:0 0 12px #fff,0 0 2px #00fff0;">
      <?php echo isset($dashboard_title) ? $dashboard_title : 'Dashboard'; ?>
    </h2>
  </div>
<?php endif; ?>
<nav class="navbar navbar-expand-lg neon-navbar" style="background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important; box-shadow: 0 2px 18px #00fff088, 0 1.5px 0 #ff61a6; border-radius: 0 0 18px 18px;">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="/php_projects/final_project1/inventory_management_system/index.php" style="color: #00fff0 !important; font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif; font-size: 1.5rem; letter-spacing: 1px;">Inventory System</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
        <?php if (isset($_SESSION['user_id'])): ?>
        <?php else: ?>
          <li class="nav-item"><a class="nav-link" href="/php_projects/final_project1/inventory_management_system/auth/login.php">Login</a></li>
          <li class="nav-item"><a class="nav-link" href="/php_projects/final_project1/inventory_management_system/auth/signup.php">Sign Up</a></li>
        <?php endif; ?>
      </ul>
    </div>
  </div>
</nav>
