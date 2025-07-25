<?php
// Redirect to login or portal based on session
session_start();
if (isset($_SESSION['role'])) {
    switch ($_SESSION['role']) {
        case 'Admin': header('Location: /php_projects/final_project1/inventory_management_system/admin/index.php'); exit;
        case 'Manager': header('Location: /php_projects/final_project1/inventory_management_system/manager/index.php'); exit;
        case 'Staff': header('Location: /php_projects/final_project1/inventory_management_system/staff/index.php'); exit;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory Management System</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        body {
            min-height: 100vh;
            min-width: 100vw;
              background: linear-gradient(135deg, #2b5876 0%, #4e4376 100%) fixed;
        }
        .neon-navbar {
            background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important;
            box-shadow: 0 2px 18px #00fff088, 0 1.5px 0 #ff61a6;
            border-radius: 0 0 18px 18px;
        }
        .neon-nav-link {
            color: #fff !important;
            font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
            font-size: 1.1rem;
            margin-left: 0.5rem;
            margin-right: 0.5rem;
            transition: color 0.3s, text-shadow 0.3s, transform 0.2s;
            text-shadow: 0 0 2px #00fff0, 0 0 2px #ff61a6;
        }
        .neon-nav-link:hover, .neon-nav-link:focus {
            color: #00fff0 !important;
            text-shadow: 0 0 16px #00fff0, 0 0 8px #ff61a6;
            transform: scale(1.08) translateY(-2px);
        }
        .neon-footer {
            background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important;
            color: #fff;
            border-top-left-radius: 18px;
            border-top-right-radius: 18px;
            box-shadow: 0 -2px 18px #00fff088, 0 -1.5px 0 #ff61a6;
            text-shadow: 0 0 8px #00fff0, 0 0 2px #ff61a6;
            letter-spacing:1px;
            font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
        }
        .hero-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #fff;
            text-shadow: 0 2px 8px #00fff0, 0 0 2px #ff61a6;
        }
        .hero-title {
            font-size: 3rem;
            font-weight: 700;
            color: #00fff0;
            font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
            text-shadow: 0 0 12px #00fff0, 0 0 2px #ff61a6;
        }
        .hero-desc {
            font-size: 1.3rem;
            margin-bottom: 2rem;
            color: #fff;
            text-shadow: 0 0 8px #00fff0, 0 0 2px #ff61a6;
        }
        .hero-btns .btn-get-started {
            background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%);
            color: #23243a;
            font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
            font-weight: bold;
            font-size: 1.2rem;
            border: none;
            box-shadow: 0 0 18px #00fff0, 0 2px 12px #ff61a6;
            min-width: 180px;
            margin: 0 0.5rem;
            transition: box-shadow 0.3s, background 0.3s, color 0.3s, transform 0.2s;
        }
        .hero-btns .btn-get-started:hover {
            background: linear-gradient(90deg, #ff61a6 0%, #00fff0 100%);
            color: #23243a;
            box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
            transform: scale(1.08) translateY(-2px);
        }
        .article-section {
            background: linear-gradient(120deg, #23243a 60%, #00fff0 100%) !important;
            border-radius: 18px;
            box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
            color: #fff;
            margin: 2rem auto 2.5rem auto;
            padding: 2.5rem 2rem 2rem 2rem;
            max-width: 900px;
            font-size: 1.15rem;
            text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
        }
        .article-section h2 {
            color: #00fff0;
            font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
            font-weight: bold;
            text-shadow: 0 0 12px #00fff0, 0 0 2px #ff61a6;
        }
        .article-section .bi {
            color: #ff61a6;
            font-size: 2.2rem;
            margin-right: 0.5rem;
            vertical-align: middle;
            filter: drop-shadow(0 0 8px #00fff0) drop-shadow(0 0 2px #ff61a6);
        }
        .neon-section-panel {
            background: linear-gradient(135deg, #1e1e2e 0%, #2b2b3c 100%) !important;
            border-radius: 18px;
            box-shadow: 0 4px 32px rgba(0, 255, 255, 0.2), 0 2px 24px rgba(255, 97, 166, 0.2);
        }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg neon-navbar">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="#" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.7rem; letter-spacing:1px; transition:color 0.3s, text-shadow 0.3s;">Inventory System</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item"><a class="nav-link neon-nav-link" href="/php_projects/final_project1/inventory_management_system/auth/login.php">Login</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="/php_projects/final_project1/inventory_management_system/auth/signup.php">Sign Up</a></li>
      </ul>
    </div>
  </div>
</nav>
<div class="hero-content text-center" style="min-height: 60vh;">
    <div class="hero-title mb-3">Inventory Management System</div>
    <div class="hero-desc mb-4">
      A modern, role-based inventory management platform for Admins, Managers, and Staff.<br>
      Easily manage users, inventory, suppliers, transactions, and requests with robust audit logging and a user-friendly interface.
    </div>
    <div class="hero-btns mb-4">
      <a href="/php_projects/final_project1/inventory_management_system/auth/login.php" class="btn btn-get-started btn-lg me-2">Get Started</a>
      <a href="/php_projects/final_project1/inventory_management_system/auth/signup.php" class="btn btn-outline-light btn-lg">Sign Up</a>
    </div>
</div>
<section class="article-section">
  <div class="mb-4">
    <h2><i class="bi bi-clipboard-data"></i> About This System</h2>
    <p>
      The <strong>Inventory Management System</strong> is a comprehensive, secure, and modern web application designed to streamline inventory operations for organizations of all sizes. With a beautiful neon-inspired interface, it empowers <span style="color:#00fff0;">Admins</span>, <span style="color:#ff61a6;">Managers</span>, and <span style="color:#ffe066;">Staff</span> to efficiently manage users, inventory, suppliers, and transactions.
    </p>
  </div>
  <div class="row text-center mb-3">
    <div class="col-md-4 mb-3">
      <i class="bi bi-person-badge" style="color:#00fff0;"></i>
      <h5 class="mt-2" style="color:#00fff0;">Role-Based Access</h5>
      <p>Admins, Managers, and Staff each have their own dashboards and permissions, ensuring security and clarity.</p>
    </div>
    <div class="col-md-4 mb-3">
      <i class="bi bi-box-seam" style="color:#ff61a6;"></i>
      <h5 class="mt-2" style="color:#ff61a6;">Inventory & Suppliers</h5>
      <p>Track stock, manage suppliers, and monitor transactions with real-time updates and detailed reporting.</p>
    </div>
    <div class="col-md-4 mb-3">
      <i class="bi bi-shield-lock" style="color:#ffe066;"></i>
      <h5 class="mt-2" style="color:#ffe066;">Audit & Security</h5>
      <p>All actions are logged for transparency and compliance. Enjoy robust authentication and data protection.</p>
    </div>
  </div>
  <div class="text-center mt-4">
    <a href="/php_projects/final_project1/inventory_management_system/auth/login.php" class="btn btn-get-started btn-lg">Get Started Now</a>
  </div>
</section>
<section class="container my-5">
  <article class="card shadow-lg border-0 neon-section-panel p-4" style="max-width: 900px; margin: 0 auto;">
    <div class="row g-0 align-items-center">
      <div class="col-md-4 text-center mb-3 mb-md-0 d-flex flex-column align-items-center justify-content-center">
        <i class="bi bi-collection-fill" style="font-size: 5rem; color: #00fff0; text-shadow: 0 0 24px #00fff0, 0 0 8px #ff61a6;"></i>
      </div>
      <div class="col-md-8">
        <h3 class="mb-3" style="color:#00fff0; font-family:'Orbitron','Segoe UI',Arial,sans-serif; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6;">Why Choose Our Inventory Management System?</h3>
        <ul class="list-unstyled mb-3" style="color:#fff; font-size:1.1rem;">
          <li class="mb-2"><i class="bi bi-lightning-charge-fill me-2" style="color:#ff61a6;"></i>Lightning-fast, intuitive dashboard for all roles</li>
          <li class="mb-2"><i class="bi bi-people-fill me-2" style="color:#00fff0;"></i>Role-based access for Admins, Managers, and Staff</li>
          <li class="mb-2"><i class="bi bi-bar-chart-fill me-2" style="color:#ffe066;"></i>Powerful reporting and analytics</li>
          <li class="mb-2"><i class="bi bi-shield-lock-fill me-2" style="color:#00fff0;"></i>Enterprise-grade security and audit logging</li>
          <li class="mb-2"><i class="bi bi-palette-fill me-2" style="color:#ff61a6;"></i>Modern neon-inspired UI for a delightful experience</li>
        </ul>
        <a href="/php_projects/final_project1/inventory_management_system/auth/login.php" class="btn btn-get-started btn-lg mt-2">Get Started</a>
      </div>
    </div>
  </article>
</section>
<footer class="neon-footer text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="/php_projects/final_project1/inventory_management_system/auth/login.php" class="btn btn-outline-neon btn-sm me-2">Login</a>
      <a href="/php_projects/final_project1/inventory_management_system/auth/signup.php" class="btn btn-outline-neon btn-sm">Sign Up</a>
    </div>
    <div style="font-size:1.1rem; color:#fff; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6;">Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by AK~~37</div>
  </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
