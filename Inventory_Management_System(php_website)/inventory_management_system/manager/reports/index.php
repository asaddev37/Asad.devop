<?php
session_start();
if (!isset($_SESSION['user_id']) || strtolower($_SESSION['role']) !== 'manager') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';

// Total Inventory Info
$total_items = $total_quantity = $total_price = 0;
$res = $conn->query("SELECT COUNT(*) as total_items, SUM(quantity) as total_quantity, SUM(quantity * unit_price) as total_price FROM Inventory");
if ($res && $row = $res->fetch_assoc()) {
    $total_items = $row['total_items'] ?? 0;
    $total_quantity = $row['total_quantity'] ?? 0;
    $total_price = $row['total_price'] ?? 0;
}

// Low Stock Inventory (<10)
$low_stock = $conn->query("SELECT * FROM Inventory WHERE quantity < 10 ORDER BY quantity ASC");

// Total Suppliers
$total_suppliers = 0;
$res = $conn->query("SELECT COUNT(*) as total_suppliers FROM Suppliers");
if ($res && $row = $res->fetch_assoc()) {
    $total_suppliers = $row['total_suppliers'] ?? 0;
}

// Total Transactions
$total_transactions = 0;
$res = $conn->query("SELECT COUNT(*) as total_transactions FROM Transactions");
if ($res && $row = $res->fetch_assoc()) {
    $total_transactions = $row['total_transactions'] ?? 0;
}

// Export CSV functionality
function export_csv($filename, $header, $rows) {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    $out = fopen('php://output', 'w');
    fputcsv($out, $header);
    foreach ($rows as $row) {
        fputcsv($out, $row);
    }
    fclose($out);
    exit;
}
if (isset($_GET['export'])) {
    if ($_GET['export'] === 'inventory') {
        $rows = [];
        $res = $conn->query("SELECT name, category, quantity, unit_price FROM Inventory");
        while ($r = $res->fetch_assoc()) $rows[] = $r;
        export_csv('total_inventory.csv', ['Name','Category','Quantity','Unit Price'], $rows);
    } elseif ($_GET['export'] === 'lowstock') {
        $rows = [];
        $res = $conn->query("SELECT name, category, quantity FROM Inventory WHERE quantity < 10");
        while ($r = $res->fetch_assoc()) $rows[] = $r;
        export_csv('low_stock_inventory.csv', ['Name','Category','Quantity'], $rows);
    } elseif ($_GET['export'] === 'suppliers') {
        $rows = [];
        $res = $conn->query("SELECT name, contact_info, address FROM Suppliers");
        while ($r = $res->fetch_assoc()) $rows[] = $r;
        export_csv('suppliers.csv', ['Name','Contact Info','Address'], $rows);
    } elseif ($_GET['export'] === 'transactions') {
        $rows = [];
        $res = $conn->query("SELECT t.id, i.name as item, t.type, t.quantity, t.transaction_date, u.username as user FROM Transactions t JOIN Inventory i ON t.item_id = i.id JOIN Users u ON t.user_id = u.id");
        while ($r = $res->fetch_assoc()) $rows[] = $r;
        export_csv('transactions.csv', ['ID','Item','Type','Quantity','Date','User'], $rows);
    }
}
?>
<div class="d-flex flex-column min-vh-100">
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container-fluid">
    <a class="navbar-brand" href="../index.php">Manager Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link" href="../inventory/index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Reports</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">Suppliers</a></li>
        <li class="nav-item"><a class="nav-link" href="../transactions/index.php">Transactions</a></li>
        <li class="nav-item"><a class="nav-link" href="../requests/index.php">Requests from Staff</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5 mb-4 flex-grow-1">
  <h2 class="mb-4">Reports & Analytics</h2>
  <div class="row g-4 mb-4">
    <div class="col-md-3">
      <div class="card shadow h-100 border-primary">
        <div class="card-body text-center">
          <h5 class="card-title">Total Inventory Items</h5>
          <p class="display-6 fw-bold text-primary"><?php echo $total_items; ?></p>
          <a href="?export=inventory" class="btn btn-outline-primary btn-sm">Export CSV</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card shadow h-100 border-success">
        <div class="card-body text-center">
          <h5 class="card-title">Total Quantity</h5>
          <p class="display-6 fw-bold text-success"><?php echo $total_quantity; ?></p>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card shadow h-100 border-warning">
        <div class="card-body text-center">
          <h5 class="card-title">Total Inventory Value</h5>
          <p class="display-6 fw-bold text-warning">₨ <?php echo number_format($total_price,2); ?></p>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card shadow h-100 border-info">
        <div class="card-body text-center">
          <h5 class="card-title">Total Suppliers</h5>
          <p class="display-6 fw-bold text-info"><?php echo $total_suppliers; ?></p>
          <a href="?export=suppliers" class="btn btn-outline-info btn-sm">Export CSV</a>
        </div>
      </div>
    </div>
  </div>
  <div class="row g-4 mb-4">
    <div class="col-md-3">
      <div class="card shadow h-100 border-secondary">
        <div class="card-body text-center">
          <h5 class="card-title">Total Transactions</h5>
          <p class="display-6 fw-bold text-secondary"><?php echo $total_transactions; ?></p>
          <a href="?export=transactions" class="btn btn-outline-secondary btn-sm">Export CSV</a>
        </div>
      </div>
    </div>
    <div class="col-md-9">
      <div class="card shadow h-100 border-danger">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <h5 class="card-title mb-0">Low Stock Inventory (<10)</h5>
            <a href="?export=lowstock" class="btn btn-outline-danger btn-sm">Export CSV</a>
          </div>
          <div class="table-responsive">
            <table class="table table-striped table-bordered mb-0">
              <thead class="table-danger">
                <tr>
                  <th>Name</th>
                  <th>Category</th>
                  <th>Quantity</th>
                  <th>Unit Price</th>
                </tr>
              </thead>
              <tbody>
                <?php if ($low_stock && $low_stock->num_rows > 0): while($row = $low_stock->fetch_assoc()): ?>
                <tr>
                  <td><?php echo htmlspecialchars($row['name']); ?></td>
                  <td><?php echo htmlspecialchars($row['category']); ?></td>
                  <td><?php echo htmlspecialchars($row['quantity']); ?></td>
                  <td><?php echo htmlspecialchars($row['unit_price']); ?></td>
                </tr>
                <?php endwhile; else: ?>
                <tr><td colspan="4" class="text-center">No low stock items.</td></tr>
                <?php endif; ?>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="../reports/index.php" class="btn btn-outline-light btn-sm me-2">Reports</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">Suppliers</a>
      <a href="../transactions/index.php" class="btn btn-outline-light btn-sm me-2">Transactions</a>
      <a href="index.php" class="btn btn-outline-light btn-sm">Requests from Staff</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>

</div>
