<?php
session_start();
if (!isset($_SESSION['user_id']) || strtolower($_SESSION['role']) !== 'staff') {
    header('Location: ../auth/login.php');
    exit;
}
include '../includes/config.php';
include '../includes/header.php';

$user_id = $_SESSION['user_id'];
$sql = "SELECT t.id, i.name AS item_name, t.type, t.quantity, t.transaction_date, t.description FROM Transactions t JOIN Inventory i ON t.item_id = i.id WHERE t.user_id = $user_id ORDER BY t.transaction_date DESC";
$result = $conn->query($sql);
$error = '';
if (!$result) {
    $error = 'Error fetching transactions: ' . $conn->error;
}
?>
<div class="d-flex flex-column min-vh-100">
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container-fluid">
    <a class="navbar-brand" href="index.php">Staff Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link" href="inventory/index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link" href="transactions/index.php">Manage Transactions</a></li>
        <li class="nav-item"><a class="nav-link" href="suppliers/index.php">View Suppliers</a></li>
        <li class="nav-item"><a class="nav-link" href="requests/create.php">Send Request to Manager</a></li>
        <li class="nav-item"><a class="nav-link active" href="view-transactions.php">View Transactions</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5 mb-4 flex-grow-1">
  <h2>Your Transaction History</h2>
  <?php if ($error): ?>
    <div class="alert alert-danger"><?php echo $error; ?></div>
  <?php endif; ?>
  <div class="table-responsive">
    <table class="table table-striped table-bordered">
      <thead class="table-dark">
        <tr>
          <th>#</th>
          <th>Item</th>
          <th>Type</th>
          <th>Quantity</th>
          <th>Date</th>
          <th>Description</th>
        </tr>
      </thead>
      <tbody>
        <?php if ($result && $result->num_rows > 0): $i = 1; while($row = $result->fetch_assoc()): ?>
        <tr>
          <td><?php echo $i++; ?></td>
          <td><?php echo htmlspecialchars($row['item_name']); ?></td>
          <td><?php echo htmlspecialchars($row['type']); ?></td>
          <td><?php echo htmlspecialchars($row['quantity']); ?></td>
          <td><?php echo htmlspecialchars($row['transaction_date']); ?></td>
          <td><?php echo htmlspecialchars($row['description']); ?></td>
        </tr>
        <?php endwhile; else: ?>
        <tr><td colspan="6" class="text-center">No transactions found.</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="transactions/index.php" class="btn btn-outline-light btn-sm me-2">Manage Transactions</a>
      <a href="suppliers/index.php" class="btn btn-outline-light btn-sm me-2">View Suppliers</a>
      <a href="requests/create.php" class="btn btn-outline-light btn-sm me-2">Send Request</a>
      <a href="view-transactions.php" class="btn btn-outline-light btn-sm">View Transactions</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
</div>
