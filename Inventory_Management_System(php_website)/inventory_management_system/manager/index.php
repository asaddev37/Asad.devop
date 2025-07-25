<?php
// Start the session
session_start();

// Check if the user is logged in and has the 'Manager' role
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Manager') {
    // If not, redirect to the login page
    header('Location: ../auth/login.php');
    exit;
}

// Include configuration
include '../includes/config.php';
include '../includes/header.php';
// Set variables to show the dashboard header with the correct title
$show_dashboard_header = true;
$dashboard_title = 'Manager Dashboard';
?>
<nav class="navbar navbar-expand-lg neon-navbar" style="background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important; box-shadow: 0 2px 18px #00fff088, 0 1.5px 0 #ff61a6; border-radius: 0 0 18px 18px;">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="index.php" style="color:#00fff0; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.7rem; letter-spacing:1px; transition:color 0.3s, text-shadow 0.3s;">Manager Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link neon-nav-link" href="inventory/index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="reports/index.php">Reports</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="suppliers/index.php">Suppliers</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="transactions/index.php">Transactions</a></li>
        <li class="nav-item"><a class="nav-link neon-nav-link" href="requests/index.php">Requests from Staff</a></li>
      </ul>
      <span class="navbar-text me-3" style="color:#00fff0; text-shadow:0 0 12px #00fff0,0 0 2px #ff61a6; font-family:'Orbitron','Segoe UI',Arial,sans-serif; font-size:1.1rem; letter-spacing:1px;">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../auth/logout.php" class="btn btn-neon logout-btn" style="margin-left:8px;">Logout</a>
    </div>
  </div>
</nav>
<div class="container py-5">
  <div class="row mb-4">
    <div class="col-lg-8 mx-auto text-center">
      <h1 class="display-4 mb-3">Welcome to the Manager Dashboard</h1>
      <p class="lead">Access inventory, reports, suppliers, and transactions. Use the navigation bar above to access each module.</p>
    </div>
  </div>
  <div>
  <div class="row g-4 justify-content-center">
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center manager-dashboard-card">
        <div class="card-body">
          <i class="bi bi-box-seam display-4 mb-3" style="color:#00fff0;"></i>
          <h5 class="card-title">Inventory</h5>
          <p class="card-text">View and manage inventory items.</p>
          <a href="inventory/index.php" class="btn btn-neon">Go to Inventory</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center manager-dashboard-card">
        <div class="card-body">
          <i class="bi bi-bar-chart-line display-4 mb-3" style="color:#00fff0;"></i>
          <h5 class="card-title">Reports</h5>
          <p class="card-text">View and export inventory and transaction reports.</p>
          <a href="reports/index.php" class="btn btn-neon">Go to Reports</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center manager-dashboard-card">
        <div class="card-body">
          <i class="bi bi-truck display-4 mb-3" style="color:#ffe066;"></i>
          <h5 class="card-title">Suppliers</h5>
          <p class="card-text">View and manage suppliers.</p>
          <a href="suppliers/index.php" class="btn btn-neon">Go to Suppliers</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center manager-dashboard-card">
        <div class="card-body">
          <i class="bi bi-arrow-left-right display-4 mb-3" style="color:#00aaff;"></i>
          <h5 class="card-title">Transactions</h5>
          <p class="card-text">View and manage inventory transactions.</p>
          <a href="transactions/index.php" class="btn btn-neon">Go to Transactions</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="neon-panel h-100 text-center manager-dashboard-card">
        <div class="card-body">
          <i class="bi bi-chat-dots-fill display-4 mb-3" style="color:#ff61a6;"></i>
          <h5 class="card-title">Requests from Staff</h5>
          <p class="card-text">View and respond to requests submitted by staff members.</p>
          <a href="requests/index.php" class="btn btn-neon">View Requests</a>
        </div>
      </div>
    </div>
  </div>
    </div>
  <div class="row mb-4">
    <div class="col-lg-8 mx-auto text-center">
      <h2 class="display-6 fw-bold text-primary mb-3" style="letter-spacing:1px;">Module Descriptions</h2>
      <p class="text-secondary mb-0">Learn about each dashboard module and how it empowers your management workflow.</p>
    </div>
  </div>
  <!-- Module Descriptions Section -->
  <div class="row mb-4">
    <div class="col-lg-8 mx-auto">
      <!-- Module Descriptions with Cards -->
      <!-- Inventory Management Description Section -->
      <div class="container mb-5">
        <div class="row justify-content-center">
          <div class="col-lg-10">
            <div class="card shadow border-success neon-section-panel">
              <div class="card-header bg-success text-white section-header">
                <h4 class="mb-0"><i class="bi bi-box-seam me-2"></i>Inventory Management</h4>
              </div>
              <div class="card-body">
                <div class="row align-items-center">
                  <div class="col-md-9">
                    <h5 class="fw-bold">What can you do?</h5>
                    <ul class="mb-3">
                      <li><strong>View Inventory:</strong> See all items, categories, quantities, and low stock alerts.</li>
                      <li><strong>Edit Items:</strong> Update item details and quantities (no add/delete).</li>
                      <li><strong>Monitor Stock:</strong> Track low stock and get alerts for restocking.</li>
                    </ul>
                    <h5 class="fw-bold">Why is this important?</h5>
                    <p class="mb-3">Inventory Management helps you keep stock levels accurate, avoid shortages, and ensure smooth operations.</p>
                    <div class="accordion neon-accordion" id="managerInventoryFAQ">
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="minvfaq1">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#minvfaq1Collapse" aria-expanded="false" aria-controls="minvfaq1Collapse">
                            Can I add or delete inventory items?
                          </button>
                        </h2>
                        <div id="minvfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="minvfaq1" data-bs-parent="#managerInventoryFAQ">
                          <div class="accordion-body">
                            Managers can only edit existing items. Adding or deleting items is reserved for Admins.
                          </div>
                        </div>
                      </div>
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="minvfaq2">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#minvfaq2Collapse" aria-expanded="false" aria-controls="minvfaq2Collapse">
                            How are low stock items highlighted?
                          </button>
                        </h2>
                        <div id="minvfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="minvfaq2" data-bs-parent="#managerInventoryFAQ">
                          <div class="accordion-body">
                            Items below the set threshold are visually highlighted for quick action.
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-3 text-center">
                    <i class="bi bi-box2-heart display-1 text-success mb-2"></i>
                    <div class="fw-bold">Accurate, Efficient, Informed</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- Reports Description Section -->
      <div class="container mb-5">
        <div class="row justify-content-center">
          <div class="col-lg-10">
            <div class="card shadow border-info neon-section-panel">
              <div class="card-header bg-info text-white section-header">
                <h4 class="mb-0"><i class="bi bi-bar-chart-line me-2"></i>Reports</h4>
              </div>
              <div class="card-body">
                <div class="row align-items-center">
                  <div class="col-md-9">
                    <h5 class="fw-bold">What can you do?</h5>
                    <ul class="mb-3">
                      <li><strong>Generate Reports:</strong> Create reports for inventory, suppliers, and transactions.</li>
                      <li><strong>Filter Data:</strong> Filter by date, category, or status.</li>
                      <li><strong>Export:</strong> Download reports as CSV files.</li>
                    </ul>
                    <h5 class="fw-bold">Why is this important?</h5>
                    <p class="mb-3">Reports help you analyze trends, monitor performance, and make informed decisions.</p>
                    <div class="accordion neon-accordion" id="managerReportsFAQ">
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="mrepfaq1">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#mrepfaq1Collapse" aria-expanded="false" aria-controls="mrepfaq1Collapse">
                            What types of reports can I generate?
                          </button>
                        </h2>
                        <div id="mrepfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="mrepfaq1" data-bs-parent="#managerReportsFAQ">
                          <div class="accordion-body">
                            You can generate reports for total inventory, low stock, suppliers, and all transaction histories.
                          </div>
                        </div>
                      </div>
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="mrepfaq2">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#mrepfaq2Collapse" aria-expanded="false" aria-controls="mrepfaq2Collapse">
                            How do I export a report?
                          </button>
                        </h2>
                        <div id="mrepfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="mrepfaq2" data-bs-parent="#managerReportsFAQ">
                          <div class="accordion-body">
                            Use the Export to CSV button in the Reports module to download the current report view.
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-3 text-center">
                    <i class="bi bi-graph-up-arrow display-1 text-info mb-2"></i>
                    <div class="fw-bold">Insightful, Exportable, Actionable</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- Supplier Management Description Section -->
      <div class="container mb-5">
        <div class="row justify-content-center">
          <div class="col-lg-10">
            <div class="card shadow border-warning neon-section-panel">
              <div class="card-header bg-warning text-dark section-header">
                <h4 class="mb-0"><i class="bi bi-truck me-2"></i>Supplier Management</h4>
              </div>
              <div class="card-body">
                <div class="row align-items-center">
                  <div class="col-md-9">
                    <h5 class="fw-bold">What can you do?</h5>
                    <ul class="mb-3">
                      <li><strong>View Suppliers:</strong> See all supplier details and contacts.</li>
                      <li><strong>Edit Suppliers:</strong> Update supplier information as needed.</li>
                    </ul>
                    <h5 class="fw-bold">Why is this important?</h5>
                    <p class="mb-3">Supplier Management ensures you have up-to-date contacts for procurement and smooth supply chain operations.</p>
                    <div class="accordion neon-accordion" id="managerSuppliersFAQ">
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="msupfaq1">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#msupfaq1Collapse" aria-expanded="false" aria-controls="msupfaq1Collapse">
                            Can I add or delete suppliers?
                          </button>
                        </h2>
                        <div id="msupfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="msupfaq1" data-bs-parent="#managerSuppliersFAQ">
                          <div class="accordion-body">
                            Managers can only edit supplier details. Adding or deleting suppliers is reserved for Admins.
                          </div>
                        </div>
                      </div>
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="msupfaq2">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#msupfaq2Collapse" aria-expanded="false" aria-controls="msupfaq2Collapse">
                            How do I update supplier information?
                          </button>
                        </h2>
                        <div id="msupfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="msupfaq2" data-bs-parent="#managerSuppliersFAQ">
                          <div class="accordion-body">
                            Click the Edit button next to a supplier to update their contact or business details.
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-3 text-center">
                    <i class="bi bi-truck display-1 text-warning mb-2"></i>
                    <div class="fw-bold">Reliable, Connected, Transparent</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- Transactions Description Section -->
      <div class="container mb-5">
        <div class="row justify-content-center">
          <div class="col-lg-10">
            <div class="card shadow border-primary neon-section-panel transactions-section-panel">
              <div class="card-header bg-primary text-white section-header transactions-section-header">
                <h4 class="mb-0"><i class="bi bi-arrow-left-right me-2"></i>Transactions</h4>
              </div>
              <div class="card-body transactions-section-body">
                <div class="row align-items-center">
                  <div class="col-md-9">
                    <h5 class="fw-bold">What can you do?</h5>
                    <ul class="mb-3">
                      <li><strong>View Transactions:</strong> See all inventory in/out and adjustment records.</li>
                      <li><strong>Edit Transactions:</strong> Update transaction details if needed.</li>
                    </ul>
                    <h5 class="fw-bold">Why is this important?</h5>
                    <p class="mb-3">Transaction records help you track inventory movement, spot discrepancies, and maintain accountability.</p>
                    <div class="accordion neon-accordion" id="managerTransactionsFAQ">
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="mtransfaq1">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#mtransfaq1Collapse" aria-expanded="false" aria-controls="mtransfaq1Collapse">
                            Can I delete transactions?
                          </button>
                        </h2>
                        <div id="mtransfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="mtransfaq1" data-bs-parent="#managerTransactionsFAQ">
                          <div class="accordion-body">
                            Managers can only view and edit transactions. Deletion is reserved for Admins.
                          </div>
                        </div>
                      </div>
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="mtransfaq2">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#mtransfaq2Collapse" aria-expanded="false" aria-controls="mtransfaq2Collapse">
                            Are all changes logged?
                          </button>
                        </h2>
                        <div id="mtransfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="mtransfaq2" data-bs-parent="#managerTransactionsFAQ">
                          <div class="accordion-body">
                            Yes, all edits are logged for audit and reporting purposes.
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-3 text-center">
                    <i class="bi bi-arrow-left-right display-1 text-primary mb-2"></i>
                    <div class="fw-bold">Tracked, Accountable, Secure</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- Requests from Staff Description Section -->
      <div class="container mb-5">
        <div class="row justify-content-center">
          <div class="col-lg-10">
            <div class="card shadow border-primary neon-section-panel transactions-section-panel">
              <div class="card-header bg-primary text-white section-header transactions-section-header">
                <h4 class="mb-0 w-100 text-center">
                  <i class="bi bi-chat-dots-fill me-2 display-5"></i>
                  Requests from Staff
                </h4>
              </div>
              <div class="card-body" style="min-height: 270px;">
                <div class="row align-items-center h-100">
                  <div class="col-md-8 col-lg-9">
                   
                    <h5 class="fw-bold">What can you do?</h5>
                    <ul class="mb-3">
                      <li><strong>View Requests:</strong> See all requests submitted by staff members.</li>
                      <li><strong>Approve/Reject:</strong> Review and respond to each request.</li>
                    </ul>
                    <h5 class="fw-bold">Why is this important?</h5>
                    <p class="mb-3">Handling staff requests efficiently ensures smooth workflow and keeps your team supported.</p>
                    <div class="accordion neon-accordion" id="managerRequestsFAQ">
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="mreqfaq1">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#mreqfaq1Collapse" aria-expanded="false" aria-controls="mreqfaq1Collapse">
                            How do I approve or reject a request?
                          </button>
                        </h2>
                        <div id="mreqfaq1Collapse" class="accordion-collapse collapse" aria-labelledby="mreqfaq1" data-bs-parent="#managerRequestsFAQ">
                          <div class="accordion-body">
                            Open the Requests module, review the details, and use the Approve or Reject buttons for each request.
                          </div>
                        </div>
                      </div>
                      <div class="accordion-item">
                        <h2 class="accordion-header" id="mreqfaq2">
                          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#mreqfaq2Collapse" aria-expanded="false" aria-controls="mreqfaq2Collapse">
                            Are staff notified of my decision?
                          </button>
                        </h2>
                        <div id="mreqfaq2Collapse" class="accordion-collapse collapse" aria-labelledby="mreqfaq2" data-bs-parent="#managerRequestsFAQ">
                          <div class="accordion-body">
                            Yes, staff members receive notifications when their requests are approved or rejected.
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4 col-lg-3 d-flex flex-column align-items-center justify-content-center">
                    <div class="rounded-circle bg-danger bg-gradient d-flex align-items-center justify-content-center mb-3" style="width: 110px; height: 110px; box-shadow: 0 0 24px 0 rgba(220,53,69,0.25);">
                      <i class="bi bi-chat-dots-fill display-2 text-white"></i>
                    </div>
                    <div class="fw-bold fs-5 text-danger text-center">Responsive, Supportive,<br>Efficient</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- End of module description cards -->
    </div>
  </div>
  
</div>
<footer class="neon-footer text-center py-4 mt-5" style="background: linear-gradient(90deg, #23243a 0%, #2b5876 100%) !important; color: #fff; border-top-left-radius: 18px; border-top-right-radius: 18px; box-shadow: 0 -2px 18px #00fff088, 0 -1.5px 0 #ff61a6; text-shadow: 0 0 8px #00fff0, 0 0 2px #ff61a6; letter-spacing:1px;">
  <div class="container">
    <div class="mb-2">
      <a href="index.php" class="btn btn-outline-neon btn-sm me-2">Dashboard</a>
      <a href="inventory/index.php" class="btn btn-outline-neon btn-sm me-2">Inventory</a>
      <a href="reports/index.php" class="btn btn-outline-neon btn-sm me-2">Reports</a>
      <a href="suppliers/index.php" class="btn btn-outline-neon btn-sm me-2">Suppliers</a>
      <a href="transactions/index.php" class="btn btn-outline-neon btn-sm me-2">Transactions</a>
      <a href="requests/index.php" class="btn btn-outline-neon btn-sm">Requests from Staff</a>
    </div>
    <div style="font-size:1.1rem; color:#fff; text-shadow:0 0 8px #00fff0,0 0 2px #ff61a6;">Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by AK~~37</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<style>
@keyframes neonPulse {
  0% { filter: drop-shadow(0 0 8px #00fff0) drop-shadow(0 0 2px #ff61a6); }
  100% { filter: drop-shadow(0 0 24px #ff61a6) drop-shadow(0 0 12px #00fff0); }
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
.neon-panel, .neon-section-panel {
  background: linear-gradient(120deg, #23243a 60%, #00fff0 100%) !important;
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  border-radius: 18px;
  transition: box-shadow 0.4s, transform 0.3s;
}
.neon-panel:hover, .neon-section-panel:hover {
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
.section-header i {
  font-size: 2.2rem;
  color: #23243a;
  text-shadow: 0 0 12px #00fff0;
  animation: neonPulse 2s infinite alternate;
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
  color: #23243a;
  background: linear-gradient(90deg, #fff 0%, #23243a 100%);
  text-shadow: 0 0 12px #fff, 0 0 8px #23243a;
}
.neon-accordion .accordion-body {
  color: #fff;
  background: rgba(35,36,58,0.85);
  border-radius: 10px;
  box-shadow: 0 0 8px #00fff0;
  transition: box-shadow 0.3s;
}
.manager-dashboard-card {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
}
.manager-dashboard-card h5,
.manager-dashboard-card p {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
}
.manager-dashboard-card .card-title {
  color: #00fff0 !important;
  font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
  font-weight: bold;
  letter-spacing: 1px;
  text-shadow: 0 0 8px #00fff0, 0 0 2px #23243a;
}
.manager-dashboard-card .card-body {
  color: #fff !important;
}
.manager-dashboard-card .bi {
  filter: drop-shadow(0 0 8px #00fff0) drop-shadow(0 0 2px #ff61a6);
}

/* Neon section panel backgrounds and icons for consistency */
.neon-section-panel {
  background: linear-gradient(120deg, #23243a 60%, #00fff0 100%) !important;
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  border-radius: 18px;
  transition: box-shadow 0.4s, transform 0.3s;
}
.neon-section-panel .section-header i,
.neon-section-panel .col-md-3 i,
.neon-section-panel .col-md-4 i,
.neon-section-panel .col-lg-3 i {
  color: #00fff0 !important;
  text-shadow: 0 0 16px #00fff0, 0 0 8px #ff61a6;
  animation: neonPulse 2s infinite alternate;
}
.neon-section-panel .fw-bold, .neon-section-panel h5 {
  color: #00fff0 !important;
  text-shadow: 0 0 8px #00fff0, 0 0 2px #23243a;
}
.neon-section-panel strong {
  color: #ff61a6 !important;
  text-shadow: 0 0 8px #ff61a6, 0 0 2px #23243a;
}
.neon-section-panel p, .neon-section-panel ul, .neon-section-panel li {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
}
/* Fix Transactions section for neon readability */
.transactions-section-panel {
  background: linear-gradient(120deg, #23243a 60%, #00fff0 100%) !important;
  box-shadow: 0 0 32px #00fff0, 0 2px 18px #ff61a6;
  border-radius: 18px;
  transition: box-shadow 0.4s, transform 0.3s;
}
.transactions-section-header {
  background: linear-gradient(90deg, #00fff0 0%, #ff61a6 100%) !important;
  color: #23243a !important;
  box-shadow: 0 2px 12px #00fff0;
}
.transactions-section-panel .section-header i,
.transactions-section-panel .col-md-3 i {
  color: #00fff0 !important;
  text-shadow: 0 0 16px #00fff0, 0 0 8px #ff61a6;
  animation: neonPulse 2s infinite alternate;
}
.transactions-section-panel .fw-bold, .transactions-section-panel h5 {
  color: #00fff0 !important;
  text-shadow: 0 0 8px #00fff0, 0 0 2px #23243a;
}
.transactions-section-panel strong {
  color: #ff61a6 !important;
  text-shadow: 0 0 8px #ff61a6, 0 0 2px #23243a;
}
.transactions-section-panel p, .transactions-section-panel ul, .transactions-section-panel li {
  color: #fff !important;
  text-shadow: 0 0 8px #23243a, 0 0 2px #00fff0;
}
</style>
