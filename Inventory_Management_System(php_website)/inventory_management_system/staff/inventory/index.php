<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Staff') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';

// Fetch inventory items with supplier info
$sql = "SELECT Inventory.id, Inventory.name, Inventory.category, Inventory.quantity, Inventory.unit_price, Inventory.last_updated, Suppliers.name AS supplier_name FROM Inventory LEFT JOIN Suppliers ON Inventory.supplier_id = Suppliers.id ORDER BY Inventory.id DESC";
$result = $conn->query($sql);
$error = '';
if (!$result) {
    $error = 'Error fetching inventory: ' . $conn->error;
}
?>
<div class="d-flex flex-column min-vh-100">
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container-fluid">
    <a class="navbar-brand" href="../index.php">Staff Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link active" href="index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link" href="../transactions/index.php">Manage Transactions</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">View Suppliers</a></li>
        <li class="nav-item"><a class="nav-link" href="../requests/create.php">Send Request to Manager</a></li>
        <li class="nav-item"><a class="nav-link" href="../view-transactions.php">View Transactions</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5 mb-4 flex-grow-1"><!-- mb-4 for footer spacing, flex-grow-1 for sticky footer -->
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Inventory</h2>
  </div>
  <?php if ($error): ?>
    <div class="alert alert-danger"><?php echo $error; ?></div>
  <?php endif; ?>
  <div class="table-responsive">
    <table id="inventoryTable" class="table table-striped table-bordered">
      <thead class="table-dark">
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Category</th>
          <th>Quantity</th>
          <th>Unit Price</th>
          <th>Supplier</th>
          <th>Last Updated</th>
        </tr>
      </thead>
      <tbody>
        <?php if ($result && $result->num_rows > 0): $i = 1; while($row = $result->fetch_assoc()): ?>
        <tr>
          <td><?php echo $i++; ?></td>
          <td><?php echo htmlspecialchars($row['name']); ?></td>
          <td><?php echo htmlspecialchars($row['category']); ?></td>
          <td><?php echo htmlspecialchars($row['quantity']); ?></td>
          <td><?php echo htmlspecialchars($row['unit_price']); ?></td>
          <td><?php echo htmlspecialchars($row['supplier_name']); ?></td>
          <td><?php echo htmlspecialchars($row['last_updated']); ?></td>
        </tr>
        <?php endwhile; else: ?>
        <tr><td colspan="7" class="text-center">No inventory items found.</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
</div>
<script>
$(document).ready(function() {
    $('#inventoryTable').DataTable();
});
</script>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="../transactions/index.php" class="btn btn-outline-light btn-sm me-2">Manage Transactions</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">View Suppliers</a>
      <a href="../requests/create.php" class="btn btn-outline-light btn-sm me-2">Send Request</a>
      <a href="../view-transactions.php" class="btn btn-outline-light btn-sm">View Transactions</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
