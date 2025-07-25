<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../auth/login.php');
    exit;
}
echo '<!-- DEBUG: admin/index.php loaded, session user_id=' . ($_SESSION['user_id'] ?? 'none') . ', role=' . ($_SESSION['role'] ?? 'none') . ' -->';

include '../includes/config.php';
if (!$conn || $conn->connect_error) {
    die('<div style="color:red;">Database connection failed: ' . htmlspecialchars($conn->connect_error) . '</div>');
}

include '../includes/header.php';
// Remove the default Bootstrap navbar and use a neon-themed navbar
?>
<nav class="navbar navbar-expand-lg neon-navbar" style="background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important; box-shadow: 0 2px 18px #00fff088, 0 1.5px 0 #ff61a6; border-radius: 0 0 18px 18px;">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="index.php" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.7rem; letter-spacing:1px; transition:color 0.3s, text-shadow 0.3s;">Admin Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link neon-nav-link" href="users/index.php">User Management</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="inventory/index.php">Inventory Management</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="suppliers/index.php">Supplier Management</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="audit-logs/index.php">Audit Logs</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="settings/index.php">Settings</a></li>
      </ul>
      <span class="navbar-text me-3" style="color:#00fff0; text-shadow:0 0 12px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.1rem; letter-spacing:1px;">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../auth/logout.php" class="btn btn-neon logout-btn" style="margin-left:8px;">Logout</a>
    </div>
  </div>
</nav>
<style>
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
.logout-btn {
  background: transparent !important;
  color: #ff61a6 !important;
  border: 2px solid #ff61a6 !important;
  transition: background 0.3s, color 0.3s, box-shadow 0.3s, transform 0.2s;
}
.logout-btn:hover, .logout-btn:focus {
  background: linear-gradient(90deg, #ff61a6 0%, #00fff0 100%) !important;
  color: #23243a !important;
  box-shadow: 0 0 18px #ff61a6, 0 2px 12px #00fff0;
  transform: scale(1.08) translateY(-2px);
}
/* Module panel and button hover/animation */
.neon-panel {
  transition: box-shadow 0.3s, transform 0.2s;
}
.neon-panel:hover {
  box-shadow: 0 0 48px #00fff0, 0 2px 32px #ff61a6;
  transform: scale(1.03) translateY(-4px);
  z-index:2;
}
.neon-panel .btn-neon {
  transition: box-shadow 0.3s, background 0.3s, color 0.3s, transform 0.2s;
}
.neon-panel .btn-neon:hover, .neon-panel .btn-neon:focus {
  background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%) !important;
  color: #23243a !important;
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  transform: scale(1.08) translateY(-2px);
}
@keyframes neonPulse {
  0% { filter: drop-shadow(0 0 8px #00fff0) drop-shadow(0 0 2px #ff61a6); }
  100% { filter: drop-shadow(0 0 24px #ff61a6) drop-shadow(0 0 12px #00fff0); }
}
.neon-section-panel {
  background: linear-gradient(120deg, #23243a 60%, #00fff0 100%);
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  border-radius: 18px;
  transition: box-shadow 0.4s, transform 0.3s;
}
.neon-section-panel:hover {
  box-shadow: 0 0 64px #00fff0, 0 2px 32px #ff61a6;
  transform: scale(1.02) translateY(-4px);
}
.section-header {
  background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%);
  border-radius: 12px;
  padding: 0.7rem 1.2rem;
  box-shadow: 0 2px 12px #00fff0;
  transition: box-shadow 0.3s, background 0.3s;
}
.section-header:hover {
  box-shadow: 0 0 24px #ff61a6, 0 2px 12px #00fff0;
  background: linear-gradient(90deg, #ff61a6 0%, #00fff0 100%);
}
.neon-accordion .accordion-button {
  background: linear-gradient(90deg, #23243a 0%, #00fff0 100%);
  color: #00fff0;
  font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
  font-weight: bold;
  transition: color 0.3s, text-shadow 0.3s, background 0.3s;
  text-shadow: 0 0 4px #00fff0, 0 0 2px #ff61a6;
  border-radius: 8px !important;
  margin-bottom: 4px;
}
.neon-accordion .accordion-button:hover, .neon-accordion .accordion-button:focus {
  color:rgb(227, 57, 182);
  background: linear-gradient(90deg, #fff 0%,rgb(35, 58, 55) 100%);
  text-shadow: 0 0 12px #fff, 0 0 8px #23243a;
}
.neon-accordion .accordion-body {
  color: #fff;
  background: rgba(35,36,58,0.85);
  border-radius: 10px;
  box-shadow: 0 0 8px #00fff0;
  transition: box-shadow 0.3s;
}
</style>
<div class="container py-5">
  <div class="row mb-4">
    <div class="col-lg-8 mx-auto text-center">
      <h1 class="display-4 mb-3" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif;">Welcome to the Admin Dashboard</h1>
      <p class="lead">Manage users, inventory, suppliers, audit logs, and system settings from one place. Use the navigation bar above to access each module.</p>
    </div>
  </div>
  <div class="row g-4 justify-content-center">
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center" style="box-shadow:0 0 32px #00fff0,0 2px 18px #ff61a6;">
        <div class="mb-3">
          <i class="bi bi-people display-4 mb-3" style="color:#00fff0; text-shadow:0 0 12px #00fff0,0 0 2px #ff61a6;"></i>
        </div>
        <h5 class="card-title" style="color:#00fff0;">User Management</h5>
        <p class="card-text">Add, edit, or remove users and assign roles.</p>
        <a href="users/index.php" class="btn btn-neon" style="background:linear-gradient(90deg,#00fff0 0%,#ff61a6 100%);color:#23243a;box-shadow:0 0 18px #00fff0,0 2px 12px #ff61a6;">Go to Users</a>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center" style="box-shadow:0 0 32px #ff61a6,0 2px 18px #00fff0;">
        <div class="mb-3">
          <i class="bi bi-box-seam display-4 mb-3" style="color:#ff61a6; text-shadow:0 0 12px #ff61a6,0 0 2px #00fff0;"></i>
        </div>
        <h5 class="card-title" style="color:#ff61a6;">Inventory Management</h5>
        <p class="card-text">View and manage all inventory items.</p>
        <a href="inventory/index.php" class="btn btn-neon" style="background:linear-gradient(90deg,#ff61a6 0%,#00fff0 100%);color:#23243a;box-shadow:0 0 18px #ff61a6,0 2px 12px #00fff0;">Go to Inventory</a>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center" style="box-shadow:0 0 32px #00fff0,0 2px 18px #ff61a6;">
        <div class="mb-3">
          <i class="bi bi-truck display-4 mb-3" style="color:#00fff0; text-shadow:0 0 12px #00fff0,0 0 2px #ff61a6;"></i>
        </div>
        <h5 class="card-title" style="color:#00fff0;">Supplier Management</h5>
        <p class="card-text">Manage supplier information and contacts.</p>
        <a href="suppliers/index.php" class="btn btn-neon" style="background:linear-gradient(90deg,#00fff0 0%,#ff61a6 100%);color:#23243a;box-shadow:0 0 18px #00fff0,0 2px 12px #ff61a6;">Go to Suppliers</a>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center" style="box-shadow:0 0 32px #ff61a6,0 2px 18px #00fff0;">
        <div class="mb-3">
          <i class="bi bi-clipboard-data display-4 mb-3" style="color:#ff61a6; text-shadow:0 0 12px #ff61a6,0 0 2px #00fff0;"></i>
        </div>
        <h5 class="card-title" style="color:#ff61a6;">Audit Logs</h5>
        <p class="card-text">Review system activity and user actions.</p>
        <a href="audit-logs/index.php" class="btn btn-neon" style="background:linear-gradient(90deg,#ff61a6 0%,#00fff0 100%);color:#23243a;box-shadow:0 0 18px #ff61a6,0 2px 12px #00fff0;">Go to Audit Logs</a>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center" style="box-shadow:0 0 32px #00fff0,0 2px 18px #ff61a6;">
        <div class="mb-3">
          <i class="bi bi-gear display-4 mb-3" style="color:#00fff0; text-shadow:0 0 12px #00fff0,0 0 2px #ff61a6;"></i>
        </div>
        <h5 class="card-title" style="color:#00fff0;">Settings</h5>
        <p class="card-text">Configure system preferences and options.</p>
        <a href="settings/index.php" class="btn btn-neon" style="background:linear-gradient(90deg,#00fff0 0%,#ff61a6 100%);color:#23243a;box-shadow:0 0 18px #00fff0,0 2px 12px #ff61a6;">Go to Settings</a>
      </div>
    </div>
  </div>
</div>
<!-- Section: User Management Description -->
<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-lg-10">
      <div class="neon-section-panel" style="background: linear-gradient(120deg, #23243a 60%, #00fff0 100%); box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6; border-radius: 18px; transition: box-shadow 0.4s, transform 0.3s;">
        <div class="section-header d-flex align-items-center mb-3" style="background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%); border-radius: 12px; padding: 0.7rem 1.2rem; box-shadow: 0 2px 12px #00fff0;">
          <i class="bi bi-people me-3" style="font-size:2.2rem; color:#23243a; text-shadow:0 0 12px #00fff0; animation: neonPulse 2s infinite alternate;"></i>
          <h4 class="mb-0" style="color:#23243a; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-weight:bold; letter-spacing:1px; text-shadow:0 0 8px #fff;">User Management</h4>
        </div>
        <div class="card-body" style="color:#fff;">
          <div class="row align-items-center">
            <div class="col-md-9">
              <h5 class="fw-bold" style="color:#00fff0;">What can you do?</h5>
              <ul class="mb-3" style="color:#fff;">
                <li><strong style="color:#ff61a6;">Add Users:</strong> Register new users and assign them roles (Admin, Manager, Staff).</li>
                <li><strong style="color:#ff61a6;">Edit Users:</strong> Update user information, change roles, or reset passwords.</li>
                <li><strong style="color:#ff61a6;">Delete Users:</strong> Remove users who no longer need access.</li>
              </ul>
              <h5 class="fw-bold" style="color:#00fff0;">Why is this important?</h5>
              <p class="mb-3">User Management is crucial for controlling access to the system, ensuring only authorized personnel can perform sensitive operations, and maintaining security and accountability across your organization.</p>
              <div class="accordion neon-accordion" id="userManagementFAQ">
                <div class="accordion-item">
                  <h2 class="accordion-header" id="faq1">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq1Collapse" aria-expanded="false" aria-controls="faq1Collapse">
                      Who can add or remove users?
                    </button>
                  </h2>
                  <div id="faq1Collapse" class="accordion-collapse collapse" aria-labelledby="faq1" data-bs-parent="#userManagementFAQ">
                    <div class="accordion-body">
                      Only Admin users have the authority to add, edit, or remove users from the system.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="faq2">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2Collapse" aria-expanded="false" aria-controls="faq2Collapse">
                      Can I reset a user's password?
                    </button>
                  </h2>
                  <div id="faq2Collapse" class="accordion-collapse collapse" aria-labelledby="faq2" data-bs-parent="#userManagementFAQ">
                    <div class="accordion-body">
                      Yes, Admins can reset passwords for any user if they forget their credentials or for security reasons.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="faq3">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3Collapse" aria-expanded="false" aria-controls="faq3Collapse">
                      Why should I keep user roles up to date?
                    </button>
                  </h2>
                  <div id="faq3Collapse" class="accordion-collapse collapse" aria-labelledby="faq3" data-bs-parent="#userManagementFAQ">
                    <div class="accordion-body">
                      Keeping user roles up to date ensures that only the right people have access to sensitive features and data, improving security and compliance.
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-3 text-center">
              <i class="bi bi-person-plus display-1 mb-2" style="color:#ff61a6; text-shadow:0 0 16px #00fff0,0 0 8px #ff61a6; animation: neonPulse 2s infinite alternate;"></i>
              <div class="fw-bold" style="color:#00fff0;">Easy, Secure, Flexible</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- Section: Inventory Management Description -->
<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-lg-10">
      <div class="neon-section-panel" style="background: linear-gradient(120deg, #23243a 60%, #ff61a6 100%); box-shadow: 0 0 32px #ff61a6, 0 2px 18px #00fff0; border-radius: 18px; transition: box-shadow 0.4s, transform 0.3s;">
        <div class="section-header d-flex align-items-center mb-3" style="background: linear-gradient(90deg, #ff61a6 0%, #00fff0 100%); border-radius: 12px; padding: 0.7rem 1.2rem; box-shadow: 0 2px 12px #ff61a6;">
          <i class="bi bi-box-seam me-3" style="font-size:2.2rem; color:#23243a; text-shadow:0 0 12px #ff61a6; animation: neonPulse 2s infinite alternate;"></i>
          <h4 class="mb-0" style="color:#23243a; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-weight:bold; letter-spacing:1px; text-shadow:0 0 8px #fff;">Inventory Management</h4>
        </div>
        <div class="card-body" style="color:#fff;">
          <div class="row align-items-center">
            <div class="col-md-9">
              <h5 class="fw-bold" style="color:#ff61a6;">What can you do?</h5>
              <ul class="mb-3" style="color:#fff;">
                <li><strong style="color:#00fff0;">View Inventory:</strong> See all items, categories, quantities, prices, and suppliers.</li>
                <li><strong style="color:#00fff0;">Add Items:</strong> Add new inventory items with detailed information.</li>
                <li><strong style="color:#00fff0;">Edit Items:</strong> Update item details, quantities, or assign suppliers.</li>
                <li><strong style="color:#00fff0;">Delete Items:</strong> Remove obsolete or incorrect inventory records.</li>
                <li><strong style="color:#00fff0;">Monitor Stock:</strong> Track low stock and get alerts for restocking.</li>
              </ul>
              <h5 class="fw-bold" style="color:#ff61a6;">Why is this important?</h5>
              <p class="mb-3">Inventory Management ensures you always know what stock you have, prevents shortages or overstocking, and helps optimize purchasing and sales decisions for your organization.</p>
              <div class="accordion neon-accordion" id="inventoryManagementFAQ">
                <div class="accordion-item">
                  <h2 class="accordion-header" id="invfaq1">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#invfaq1Collapse" aria-expanded="false" aria-controls="invfaq1Collapse">
                      Can I assign suppliers to inventory items?
                    </button>
                  </h2>
                  <div id="invfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="invfaq1" data-bs-parent="#inventoryManagementFAQ">
                    <div class="accordion-body">
                      Yes, you can link each inventory item to a supplier for better tracking and reordering.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="invfaq2">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#invfaq2Collapse" aria-expanded="false" aria-controls="invfaq2Collapse">
                      How do I know when stock is low?
                    </button>
                  </h2>
                  <div id="invfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="invfaq2" data-bs-parent="#inventoryManagementFAQ">
                    <div class="accordion-body">
                      The system highlights low stock items and provides reports so you can restock in time.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="invfaq3">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#invfaq3Collapse" aria-expanded="false" aria-controls="invfaq3Collapse">
                      Can I export inventory data?
                    </button>
                  </h2>
                  <div id="invfaq3Collapse" class="accordion-collapse collapse" aria-labelledby="invfaq3" data-bs-parent="#inventoryManagementFAQ">
                    <div class="accordion-body">
                      Yes, you can export inventory lists and reports as CSV files for further analysis or record-keeping.
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-3 text-center">
              <i class="bi bi-box2-heart display-1 mb-2" style="color:#00fff0; text-shadow:0 0 16px #ff61a6,0 0 8px #00fff0; animation: neonPulse 2s infinite alternate;"></i>
              <div class="fw-bold" style="color:#ff61a6;">Accurate, Efficient, Informed</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- Section: Supplier Management Description -->
<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-lg-10">
      <div class="neon-section-panel" style="background: linear-gradient(120deg, #23243a 60%, #00fff0 100%); box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6; border-radius: 18px; transition: box-shadow 0.4s, transform 0.3s;">
        <div class="section-header d-flex align-items-center mb-3" style="background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%); border-radius: 12px; padding: 0.7rem 1.2rem; box-shadow: 0 2px 12px #00fff0;">
          <i class="bi bi-truck me-3" style="font-size:2.2rem; color:#23243a; text-shadow:0 0 12px #00fff0; animation: neonPulse 2s infinite alternate;"></i>
          <h4 class="mb-0" style="color:#23243a; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-weight:bold; letter-spacing:1px; text-shadow:0 0 8px #fff;">Supplier Management</h4>
        </div>
        <div class="card-body" style="color:#fff;">
          <div class="row align-items-center">
            <div class="col-md-9">
              <h5 class="fw-bold" style="color:#00fff0;">What can you do?</h5>
              <ul class="mb-3" style="color:#fff;">
                <li><strong style="color:#ff61a6;">Add Suppliers:</strong> Register new suppliers with contact and address details.</li>
                <li><strong style="color:#ff61a6;">Edit Suppliers:</strong> Update supplier information as needed.</li>
                <li><strong style="color:#ff61a6;">Delete Suppliers:</strong> Remove suppliers that are no longer active.</li>
                <li><strong style="color:#ff61a6;">Link to Inventory:</strong> Assign suppliers to inventory items for better tracking.</li>
              </ul>
              <h5 class="fw-bold" style="color:#00fff0;">Why is this important?</h5>
              <p class="mb-3">Supplier Management helps you maintain strong relationships, ensures timely restocking, and provides transparency in your supply chain.</p>
              <div class="accordion neon-accordion" id="supplierManagementFAQ">
                <div class="accordion-item">
                  <h2 class="accordion-header" id="supfaq1">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#supfaq1Collapse" aria-expanded="false" aria-controls="supfaq1Collapse">
                      Can I assign multiple suppliers to one item?
                    </button>
                  </h2>
                  <div id="supfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="supfaq1" data-bs-parent="#supplierManagementFAQ">
                    <div class="accordion-body">
                      Currently, each inventory item can be linked to one primary supplier for clarity and simplicity.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="supfaq2">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#supfaq2Collapse" aria-expanded="false" aria-controls="supfaq2Collapse">
                      What information is stored for each supplier?
                    </button>
                  </h2>
                  <div id="supfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="supfaq2" data-bs-parent="#supplierManagementFAQ">
                    <div class="accordion-body">
                      Supplier name, contact info, and address are stored for easy communication and record-keeping.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="supfaq3">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#supfaq3Collapse" aria-expanded="false" aria-controls="supfaq3Collapse">
                      Why keep supplier records up to date?
                    </button>
                  </h2>
                  <div id="supfaq3Collapse" class="accordion-collapse collapse" aria-labelledby="supfaq3" data-bs-parent="#supplierManagementFAQ">
                    <div class="accordion-body">
                      Up-to-date supplier records help ensure smooth operations, timely deliveries, and quick resolution of issues.
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-3 text-center">
              <i class="bi bi-truck display-1 mb-2" style="color:#ff61a6; text-shadow:0 0 16px #00fff0,0 0 8px #ff61a6; animation: neonPulse 2s infinite alternate;"></i>
              <div class="fw-bold" style="color:#00fff0;">Reliable, Connected, Transparent</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- Section: Audit Logs Description -->
<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-lg-10">
      <div class="neon-section-panel" style="background: linear-gradient(120deg, #23243a 60%, #ff61a6 100%); box-shadow: 0 0 32px #ff61a6, 0 2px 18px #00fff0; border-radius: 18px; transition: box-shadow 0.4s, transform 0.3s;">
        <div class="section-header d-flex align-items-center mb-3" style="background: linear-gradient(90deg, #ff61a6 0%, #00fff0 100%); border-radius: 12px; padding: 0.7rem 1.2rem; box-shadow: 0 2px 12px #ff61a6;">
          <i class="bi bi-clipboard-data me-3" style="font-size:2.2rem; color:#23243a; text-shadow:0 0 12px #ff61a6; animation: neonPulse 2s infinite alternate;"></i>
          <h4 class="mb-0" style="color:#23243a; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-weight:bold; letter-spacing:1px; text-shadow:0 0 8px #fff;">Audit Logs</h4>
        </div>
        <div class="card-body" style="color:#fff;">
          <div class="row align-items-center">
            <div class="col-md-9">
              <h5 class="fw-bold" style="color:#ff61a6;">What can you do?</h5>
              <ul class="mb-3" style="color:#fff;">
                <li><strong style="color:#00fff0;">View Logs:</strong> See a detailed record of all system activities and user actions.</li>
                <li><strong style="color:#00fff0;">Filter by User or Action:</strong> Find specific events quickly.</li>
                <li><strong style="color:#00fff0;">Export Logs:</strong> Download logs for compliance or review.</li>
              </ul>
              <h5 class="fw-bold" style="color:#ff61a6;">Why is this important?</h5>
              <p class="mb-3">Audit Logs provide transparency, accountability, and help with troubleshooting and compliance requirements.</p>
              <div class="accordion neon-accordion" id="auditLogsFAQ">
                <div class="accordion-item">
                  <h2 class="accordion-header" id="auditfaq1">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#auditfaq1Collapse" aria-expanded="false" aria-controls="auditfaq1Collapse">
                      Who can view audit logs?
                    </button>
                  </h2>
                  <div id="auditfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="auditfaq1" data-bs-parent="#auditLogsFAQ">
                    <div class="accordion-body">
                      Only Admins have access to view and export audit logs for security reasons.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="auditfaq2">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#auditfaq2Collapse" aria-expanded="false" aria-controls="auditfaq2Collapse">
                      What kind of actions are logged?
                    </button>
                  </h2>
                  <div id="auditfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="auditfaq2" data-bs-parent="#auditLogsFAQ">
                    <div class="accordion-body">
                      Actions like user logins, edits, deletions, inventory changes, and supplier updates are all recorded.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="auditfaq3">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#auditfaq3Collapse" aria-expanded="false" aria-controls="auditfaq3Collapse">
                      Why are audit logs important?
                    </button>
                  </h2>
                  <div id="auditfaq3Collapse" class="accordion-collapse collapse" aria-labelledby="auditfaq3" data-bs-parent="#auditLogsFAQ">
                    <div class="accordion-body">
                      Audit logs help you track changes, investigate issues, and meet regulatory requirements for your organization.
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-3 text-center">
              <i class="bi bi-clipboard-check display-1 mb-2" style="color:#00fff0; text-shadow:0 0 16px #ff61a6,0 0 8px #00fff0; animation: neonPulse 2s infinite alternate;"></i>
              <div class="fw-bold" style="color:#ff61a6;">Transparent, Accountable, Secure</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- Section: Settings Description -->
<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-lg-10">
      <div class="neon-section-panel" style="background: linear-gradient(120deg, #23243a 60%, #00fff0 100%); box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6; border-radius: 18px; transition: box-shadow 0.4s, transform 0.3s;">
        <div class="section-header d-flex align-items-center mb-3" style="background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%); border-radius: 12px; padding: 0.7rem 1.2rem; box-shadow: 0 2px 12px #00fff0;">
          <i class="bi bi-gear me-3" style="font-size:2.2rem; color:#23243a; text-shadow:0 0 12px #00fff0; animation: neonPulse 2s infinite alternate;"></i>
          <h4 class="mb-0" style="color:#23243a; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-weight:bold; letter-spacing:1px; text-shadow:0 0 8px #fff;">Settings</h4>
        </div>
        <div class="card-body" style="color:#fff;">
          <div class="row align-items-center">
            <div class="col-md-9">
              <h5 class="fw-bold" style="color:#00fff0;">What can you do?</h5>
              <ul class="mb-3" style="color:#fff;">
                <li><strong style="color:#ff61a6;">Configure Preferences:</strong> Set system-wide options and preferences.</li>
                <li><strong style="color:#ff61a6;">Update Profile:</strong> Change your own account details and password.</li>
                <li><strong style="color:#ff61a6;">Manage Notifications:</strong> Enable or disable system notifications.</li>
              </ul>
              <h5 class="fw-bold" style="color:#00fff0;">Why is this important?</h5>
              <p class="mb-3">Settings allow you to tailor the system to your organization's needs, improve usability, and keep your account secure.</p>
              <div class="accordion neon-accordion" id="settingsFAQ">
                <div class="accordion-item">
                  <h2 class="accordion-header" id="setfaq1">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#setfaq1Collapse" aria-expanded="false" aria-controls="setfaq1Collapse">
                      Who can change system settings?
                    </button>
                  </h2>
                  <div id="setfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="setfaq1" data-bs-parent="#settingsFAQ">
                    <div class="accordion-body">
                      Only Admins can change global system settings. All users can update their own profile and password.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="setfaq2">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#setfaq2Collapse" aria-expanded="false" aria-controls="setfaq2Collapse">
                      Can I manage email or SMS notifications?
                    </button>
                  </h2>
                  <div id="setfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="setfaq2" data-bs-parent="#settingsFAQ">
                    <div class="accordion-body">
                      Yes, you can enable or disable notifications for important system events in the settings module.
                    </div>
                  </div>
                </div>
                <div class="accordion-item">
                  <h2 class="accordion-header" id="setfaq3">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#setfaq3Collapse" aria-expanded="false" aria-controls="setfaq3Collapse">
                      Why keep your profile updated?
                    </button>
                  </h2>
                  <div id="setfaq3Collapse" class="accordion-collapse collapse" aria-labelledby="setfaq3" data-bs-parent="#settingsFAQ">
                    <div class="accordion-body">
                      Keeping your profile updated ensures you receive important communications and your account remains secure.
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-3 text-center">
              <i class="bi bi-person-gear display-1 mb-2" style="color:#ff61a6; text-shadow:0 0 16px #00fff0,0 0 8px #ff61a6; animation: neonPulse 2s infinite alternate;"></i>
              <div class="fw-bold" style="color:#00fff0;">Personalized, Secure, Flexible</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<footer class="neon-footer text-center py-4 mt-5" style="background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important; color: #fff; border-top-left-radius: 18px; border-top-right-radius: 18px; box-shadow: 0 -2px 18px #00fff088, 0 -1.5px 0 #ff61a6; text-shadow: 0 0 8px #00fff0, 0 0 2px #ff61a6; letter-spacing:1px;">
  <div class="container">
    <div class="mb-2">
      <a href="index.php" class="btn btn-outline-neon btn-sm me-2">Dashboard</a>
      <a href="users/index.php" class="btn btn-outline-neon btn-sm me-2">Users</a>
      <a href="inventory/index.php" class="btn btn-outline-neon btn-sm me-2">Inventory</a>
      <a href="suppliers/index.php" class="btn btn-outline-neon btn-sm me-2">Suppliers</a>
      <a href="audit-logs/index.php" class="btn btn-outline-neon btn-sm me-2">Audit Logs</a>
      <a href="settings/index.php" class="btn btn-outline-neon btn-sm">Settings</a>
    </div>
    <div style="font-size:1.1rem; color:#fff; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6;">Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by AK~~37</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<?php // No need to include footer.php since custom footer is used above ?>
