<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Staff') {
    header('Location: ../auth/login.php');
    exit;
}
include '../includes/config.php';
include '../includes/header.php';

$show_dashboard_header = true;
$dashboard_title = 'Staff Dashboard';
// DO NOT include header.php here. Use the custom dashboard header below.
?>
<style>
/* Neon/gradient header, nav, and footer from admin dashboard */
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
.manager-dashboard-card {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
  border-radius: 18px !important;
  background: linear-gradient(120deg, #23243a 60%, #00fff0 100%) !important;
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  border: none;
  min-height: 320px;
  max-width: 370px;
  width: 100%;
  margin-left: auto;
  margin-right: auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transition: box-shadow 0.3s, transform 0.2s;
  padding: 2.2rem 1.2rem 1.5rem 1.2rem;
}
.manager-dashboard-card:hover {
  box-shadow: 0 0 64px #00fff0, 0 2px 32px #ff61a6;
  transform: scale(1.03) translateY(-4px);
}
.manager-dashboard-card .card-title {
  color: #00fff0 !important;
  font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
  font-weight: bold;
  letter-spacing: 1px;
  text-shadow: 0 0 8px #00fff0, 0 0 2px #23243a;
  font-size: 1.25rem;
  margin-bottom: 0.7rem;
}
.manager-dashboard-card .card-text {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
  font-size: 1.05rem;
  margin-bottom: 1.2rem;
}
.manager-dashboard-card .bi {
  filter: drop-shadow(0 0 8px #00fff0) drop-shadow(0 0 2px #ff61a6);
}
.neon-section-panel {
  background: linear-gradient(120deg, #23243a 60%, #00fff0 100%) !important;
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  border-radius: 18px;
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
  margin-bottom: 2rem;
}
.neon-section-panel .card-header {
  background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%) !important;
  color: #23243a !important;
  font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
  font-weight: bold;
  font-size: 1.2rem;
  border-radius: 12px 12px 0 0;
  box-shadow: 0 2px 12px #00fff0;
  text-shadow: 0 0 8px #fff;
}
.neon-section-panel .card-body,
.neon-section-panel ul,
.neon-section-panel p,
.neon-section-panel h5,
.neon-section-panel li,
.neon-section-panel .fw-bold {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
}
.neon-accordion .accordion-button {
  background: linear-gradient(90deg, #23243a 0%, #00fff0 100%) !important;
  color: #00fff0 !important;
  font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
  font-weight: bold;
  transition: color 0.3s, text-shadow 0.3s, background 0.3s;
  text-shadow: 0 0 4px #00fff0, 0 0 2px #ff61a6;
  border-radius: 8px !important;
  margin-bottom: 4px;
}
.neon-accordion .accordion-button:hover, .neon-accordion .accordion-button:focus {
  color: #ff61a6 !important;
  background: linear-gradient(90deg, #fff 0%, #23243a 100%) !important;
  text-shadow: 0 0 12px #fff, 0 0 8px #23243a;
}
.neon-accordion .accordion-body {
  color: #fff !important;
  background: rgba(35,36,58,0.85) !important;
  border-radius: 10px;
  box-shadow: 0 0 8px #00fff0;
  transition: box-shadow 0.3s;
}
body {
  background: linear-gradient(120deg, #23243a 60%, #2b5876 100%) fixed !important;
}
</style>
<nav class="navbar navbar-expand-lg neon-navbar">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="index.php" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.7rem; letter-spacing:1px; transition:color 0.3s, text-shadow 0.3s;">Staff Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link neon-nav-link" href="inventory/index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="transactions/index.php">Manage Transactions</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="suppliers/index.php">Suppliers</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="requests/create.php">Send Request</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="view-transactions.php">View Transactions</a></li>
      </ul>
      <span class="navbar-text me-3" style="color:#00fff0; text-shadow:0 0 12px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.1rem; letter-spacing:1px;">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../auth/logout.php" class="btn btn-neon logout-btn" style="margin-left:8px;">Logout</a>
    </div>
  </div>
</nav>
<div class="container py-5">
  <div class="row mb-4">
    <div class="col-lg-8 mx-auto text-center">
      <h1 class="display-4 mb-3" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif;">Welcome to the Staff Dashboard</h1>
      <p class="lead">Access inventory, manage transactions, view suppliers, send requests to manager, and view your transaction history. Use the navigation bar above to access each module.</p>
    </div>
  </div>
  <div class="row g-4 justify-content-center">
    <div class="col-md-4 d-flex align-items-stretch">
      <div class="neon-panel h-100 text-center manager-dashboard-card w-100">
        <div class="card-body">
          <i class="bi bi-box-seam display-4 mb-3" style="color:#00fff0;"></i>
          <h5 class="card-title">Inventory</h5>
          <p class="card-text">View inventory items.</p>
          <a href="inventory/index.php" class="btn btn-neon mt-auto">Go to Inventory</a>
        </div>
      </div>
    </div>
    <div class="col-md-4 d-flex align-items-stretch">
      <div class="neon-panel h-100 text-center manager-dashboard-card w-100">
        <div class="card-body">
          <i class="bi bi-arrow-left-right display-4 mb-3" style="color:#00fff0;"></i>
          <h5 class="card-title">Manage Transactions</h5>
          <p class="card-text">Add or update inventory transactions.</p>
          <a href="transactions/index.php" class="btn btn-neon mt-auto">Go to Transactions</a>
        </div>
      </div>
    </div>
    <div class="col-md-4 d-flex align-items-stretch">
      <div class="neon-panel h-100 text-center manager-dashboard-card w-100">
        <div class="card-body">
          <i class="bi bi-truck display-4 mb-3" style="color:#ffe066;"></i>
          <h5 class="card-title">View Suppliers</h5>
          <p class="card-text">See supplier information.</p>
          <a href="suppliers/index.php" class="btn btn-neon mt-auto">Go to Suppliers</a>
        </div>
      </div>
    </div>
    <div class="col-md-4 d-flex align-items-stretch">
      <div class="neon-panel h-100 text-center manager-dashboard-card w-100">
        <div class="card-body">
          <i class="bi bi-send display-4 mb-3" style="color:#ff61a6;"></i>
          <h5 class="card-title">Send Request to Manager</h5>
          <p class="card-text">Request inventory or actions from your manager.</p>
          <a href="requests/create.php" class="btn btn-neon mt-auto">Send Request</a>
        </div>
      </div>
    </div>
    <div class="col-md-4 d-flex align-items-stretch">
      <div class="neon-panel h-100 text-center manager-dashboard-card w-100">
        <div class="card-body">
          <i class="bi bi-list-check display-4 mb-3" style="color:#00fff0;"></i>
          <h5 class="card-title">View Transactions</h5>
          <p class="card-text">See your transaction history.</p>
          <a href="view-transactions.php" class="btn btn-neon mt-auto">View Transactions</a>
        </div>
      </div>
    </div>
  </div>
  <!-- Module Descriptions Section -->
  <div class="container mb-5">
    <div class="row mb-4">
      <div class="col-lg-8 mx-auto text-center">
        <h2 class="display-6 fw-bold" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; letter-spacing:1px;">Module Descriptions</h2>
        <p style="color:#fff; text-shadow:0 0 8px #23243a,0 0 2px #00fff0;">Learn about each dashboard module and how it helps you as a staff member.</p>
      </div>
    </div>
    <!-- Inventory -->
    <div class="row justify-content-center mb-4">
      <div class="col-lg-10">
        <div class="card shadow neon-section-panel">
          <div class="card-header">
            <h4 class="mb-0"><i class="bi bi-box-seam me-2"></i>Inventory</h4>
          </div>
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-9">
                <h5 class="fw-bold">What can you do?</h5>
                <ul class="mb-3">
                  <li><strong>View Inventory:</strong> See all available items, categories, and quantities.</li>
                  <li><strong>Check Stock:</strong> Monitor stock levels before making requests or transactions.</li>
                </ul>
                <h5 class="fw-bold">Why is this important?</h5>
                <p class="mb-3">Inventory access helps you make informed requests and avoid unnecessary shortages.</p>
                <div class="accordion neon-accordion" id="staffInventoryFAQ">
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="sifaq1">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#sifaq1Collapse" aria-expanded="false" aria-controls="sifaq1Collapse">
                        Can I edit inventory items?
                      </button>
                    </h2>
                    <div id="sifaq1Collapse" class="accordion-collapse collapse" aria-labelledby="sifaq1" data-bs-parent="#staffInventoryFAQ">
                      <div class="accordion-body">
                        No, staff can only view inventory. Editing is reserved for managers and admins.
                      </div>
                    </div>
                  </div>
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="sifaq2">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#sifaq2Collapse" aria-expanded="false" aria-controls="sifaq2Collapse">
                        How do I request an item?
                      </button>
                    </h2>
                    <div id="sifaq2Collapse" class="accordion-collapse collapse" aria-labelledby="sifaq2" data-bs-parent="#staffInventoryFAQ">
                      <div class="accordion-body">
                        Use the Send Request module to request items from your manager.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-3 text-center">
                <i class="bi bi-box2-heart display-1 text-success mb-2"></i>
                <div class="fw-bold">Accessible, Informative</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Manage Transactions -->
    <div class="row justify-content-center mb-4">
      <div class="col-lg-10">
        <div class="card shadow border-primary neon-section-panel">
          <div class="card-header bg-primary text-white">
            <h4 class="mb-0"><i class="bi bi-arrow-left-right me-2"></i>Manage Transactions</h4>
          </div>
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-9">
                <h5 class="fw-bold">What can you do?</h5>
                <ul class="mb-3">
                  <li><strong>Add Transactions:</strong> Record inventory in/out or adjustments.</li>
                  <li><strong>Update Transactions:</strong> Edit your own transaction records if needed.</li>
                </ul>
                <h5 class="fw-bold">Why is this important?</h5>
                <p class="mb-3">Accurate transaction records help keep inventory up to date and ensure accountability.</p>
                <div class="accordion neon-accordion" id="staffTransactionsFAQ">
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="stfaq1">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#stfaq1Collapse" aria-expanded="false" aria-controls="stfaq1Collapse">
                        Can I delete transactions?
                      </button>
                    </h2>
                    <div id="stfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="stfaq1" data-bs-parent="#staffTransactionsFAQ">
                      <div class="accordion-body">
                        No, staff can only add or update their own transactions. Deletion is not allowed.
                      </div>
                    </div>
                  </div>
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="stfaq2">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#stfaq2Collapse" aria-expanded="false" aria-controls="stfaq2Collapse">
                        Are my changes tracked?
                      </button>
                    </h2>
                    <div id="stfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="stfaq2" data-bs-parent="#staffTransactionsFAQ">
                      <div class="accordion-body">
                        Yes, all transaction changes are logged for audit and review.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-3 text-center">
                <i class="bi bi-arrow-left-right display-1 text-primary mb-2"></i>
                <div class="fw-bold">Accurate, Accountable</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Suppliers -->
    <div class="row justify-content-center mb-4">
      <div class="col-lg-10">
        <div class="card shadow border-warning neon-section-panel">
          <div class="card-header bg-warning text-dark">
            <h4 class="mb-0"><i class="bi bi-truck me-2"></i>Suppliers</h4>
          </div>
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-9">
                <h5 class="fw-bold">What can you do?</h5>
                <ul class="mb-3">
                  <li><strong>View Suppliers:</strong> See supplier names and contact details.</li>
                </ul>
                <h5 class="fw-bold">Why is this important?</h5>
                <p class="mb-3">Supplier info helps you know where inventory comes from and who to contact for issues.</p>
                <div class="accordion neon-accordion" id="staffSuppliersFAQ">
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="ssfaq1">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#ssfaq1Collapse" aria-expanded="false" aria-controls="ssfaq1Collapse">
                        Can I edit supplier information?
                      </button>
                    </h2>
                    <div id="ssfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="ssfaq1" data-bs-parent="#staffSuppliersFAQ">
                      <div class="accordion-body">
                        No, staff can only view supplier information. Editing is for managers and admins.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-3 text-center">
                <i class="bi bi-truck display-1 text-warning mb-2"></i>
                <div class="fw-bold">Transparent, Connected</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Send Request -->
    <div class="row justify-content-center mb-4">
      <div class="col-lg-10">
        <div class="card shadow border-info neon-section-panel">
          <div class="card-header bg-info text-white">
            <h4 class="mb-0"><i class="bi bi-send me-2"></i>Send Request to Manager</h4>
          </div>
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-9">
                <h5 class="fw-bold">What can you do?</h5>
                <ul class="mb-3">
                  <li><strong>Request Items:</strong> Ask your manager for inventory or support.</li>
                  <li><strong>Track Requests:</strong> See the status of your submitted requests.</li>
                </ul>
                <h5 class="fw-bold">Why is this important?</h5>
                <p class="mb-3">Sending requests helps you get what you need to do your job efficiently and keeps communication clear.</p>
                <div class="accordion neon-accordion" id="staffRequestFAQ">
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="srfaq1">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#srfaq1Collapse" aria-expanded="false" aria-controls="srfaq1Collapse">
                        How do I know if my request is approved?
                      </button>
                    </h2>
                    <div id="srfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="srfaq1" data-bs-parent="#staffRequestFAQ">
                      <div class="accordion-body">
                        You will see the status update in the Send Request module and may receive a notification.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-3 text-center">
                <i class="bi bi-send display-1 text-info mb-2"></i>
                <div class="fw-bold">Empowered, Connected</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- View Transactions -->
    <div class="row justify-content-center mb-4">
      <div class="col-lg-10">
        <div class="card shadow border-secondary neon-section-panel">
          <div class="card-header bg-secondary text-white">
            <h4 class="mb-0"><i class="bi bi-list-check me-2"></i>View Transactions</h4>
          </div>
          <div class="card-body">
            <div class="row align-items-center">
              <div class="col-md-9">
                <h5 class="fw-bold">What can you do?</h5>
                <ul class="mb-3">
                  <li><strong>View History:</strong> See all your past inventory transactions.</li>
                </ul>
                <h5 class="fw-bold">Why is this important?</h5>
                <p class="mb-3">Viewing your transaction history helps you track your work and resolve any issues quickly.</p>
                <div class="accordion neon-accordion" id="staffViewTransFAQ">
                  <div class="accordion-item">
                    <h2 class="accordion-header" id="svtfaq1">
                      <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#svtfaq1Collapse" aria-expanded="false" aria-controls="svtfaq1Collapse">
                        Can I see transactions by other staff?
                      </button>
                    </h2>
                    <div id="svtfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="svtfaq1" data-bs-parent="#staffViewTransFAQ">
                      <div class="accordion-body">
                        No, you can only view your own transaction history for privacy and security.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-3 text-center">
                <i class="bi bi-list-check display-1 text-secondary mb-2"></i>
                <div class="fw-bold">Personal, Secure</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <!-- End of module description cards -->
</div>
<footer class="neon-footer text-center py-4 mt-5" style="background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important; color: #fff; border-top-left-radius: 18px; border-top-right-radius: 18px; box-shadow: 0 -2px 18px #00fff088, 0 -1.5px 0 #ff61a6; text-shadow: 0 0 8px #00fff0, 0 0 2px #ff61a6; letter-spacing:1px;">
  <div class="container">
    <div class="mb-2">
      <a href="index.php" class="btn btn-outline-neon btn-sm me-2">Dashboard</a>
      <a href="inventory/index.php" class="btn btn-outline-neon btn-sm me-2">Inventory</a>
      <a href="transactions/index.php" class="btn btn-outline-neon btn-sm me-2">Manage Transactions</a>
      <a href="suppliers/index.php" class="btn btn-outline-neon btn-sm me-2">Suppliers</a>
      <a href="requests/create.php" class="btn btn-outline-neon btn-sm me-2">Send Request</a>
      <a href="view-transactions.php" class="btn btn-outline-neon btn-sm">View Transactions</a>
    </div>
    <div style="font-size:1.1rem; color:#fff; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6;">Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by AK~~37</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
