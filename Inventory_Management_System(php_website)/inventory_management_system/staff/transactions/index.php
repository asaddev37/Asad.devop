<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Staff') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';
include '../../includes/functions.php';

// Handle add transaction
$add_error = '';
$add_success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_transaction'])) {
    $item_id = intval($_POST['item_id']);
    $type = $_POST['type'];
    $quantity = intval($_POST['quantity']);
    $description = trim($_POST['description']);
    $user_id = $_SESSION['user_id'];
    if ($item_id && $type && $quantity > 0) {
        $stmt = $conn->prepare("INSERT INTO Transactions (item_id, user_id, type, quantity, description) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param('iisis', $item_id, $user_id, $type, $quantity, $description);
        if ($stmt->execute()) {
            $add_success = 'Transaction added successfully!';
            logActivity($user_id, 'Add Transaction', 'Added transaction for item ID: ' . $item_id . ', type: ' . $type . ', qty: ' . $quantity);
        } else {
            $add_error = 'Error adding transaction.';
        }
        $stmt->close();
    } else {
        $add_error = 'Please fill all fields and enter a valid quantity.';
    }
}
// Fetch inventory for dropdown
$inventory = $conn->query("SELECT id, name FROM Inventory ORDER BY name ASC");
// Fetch transactions for this staff
$sql = "SELECT t.id, i.name AS item_name, t.type, t.quantity, t.transaction_date, t.description FROM Transactions t JOIN Inventory i ON t.item_id = i.id WHERE t.user_id = " . intval($_SESSION['user_id']) . " ORDER BY t.transaction_date DESC";
$result = $conn->query($sql);
$error = '';
if (!$result) {
    $error = 'Error fetching transactions: ' . $conn->error;
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
        <li class="nav-item"><a class="nav-link" href="../inventory/index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Manage Transactions</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">View Suppliers</a></li>
        <li class="nav-item"><a class="nav-link" href="../requests/create.php">Send Request to Manager</a></li>
        <li class="nav-item"><a class="nav-link" href="../view-transactions.php">View Transactions</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5 mb-4 flex-grow-1">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Manage Transactions</h2>
  </div>
  <?php if ($add_success): ?><div class="alert alert-success"><?php echo $add_success; ?></div><?php endif; ?>
  <?php if ($add_error): ?><div class="alert alert-danger"><?php echo $add_error; ?></div><?php endif; ?>
  <div class="card mb-4">
    <div class="card-header bg-primary text-white">Add Transaction</div>
    <div class="card-body">
      <form method="post">
        <div class="row g-3 align-items-end">
          <div class="col-md-4">
            <label for="item_id" class="form-label">Inventory Item</label>
            <select name="item_id" id="item_id" class="form-select" required>
              <option value="">Select Item</option>
              <?php if ($inventory && $inventory->num_rows > 0): while($inv = $inventory->fetch_assoc()): ?>
                <option value="<?php echo $inv['id']; ?>"><?php echo htmlspecialchars($inv['name']); ?></option>
              <?php endwhile; endif; ?>
            </select>
          </div>
          <div class="col-md-2">
            <label for="type" class="form-label">Type</label>
            <select name="type" id="type" class="form-select" required>
              <option value="Add">Add</option>
              <option value="Remove">Remove</option>
              <option value="Update">Update</option>
            </select>
          </div>
          <div class="col-md-2">
            <label for="quantity" class="form-label">Quantity</label>
            <input type="number" name="quantity" id="quantity" class="form-control" min="1" required>
          </div>
          <div class="col-md-4">
            <label for="description" class="form-label">Description</label>
            <input type="text" name="description" id="description" class="form-control">
          </div>
        </div>
        <div class="mt-3 text-end">
          <button type="submit" name="add_transaction" class="btn btn-primary">Add Transaction</button>
        </div>
      </form>
    </div>
  </div>
  <div class="table-responsive">
    <table id="transactionsTable" class="table table-striped table-bordered">
      <thead class="table-dark">
        <tr>
          <th>Item</th>
          <th>Type</th>
          <th>Quantity</th>
          <th>Date</th>
          <th>Description</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <?php 
        if ($result && $result->num_rows > 0): 
          while($row = $result->fetch_assoc()): ?>
        <tr>
          <td><?php echo htmlspecialchars($row['item_name']); ?></td>
          <td><?php echo htmlspecialchars($row['type']); ?></td>
          <td><?php echo htmlspecialchars($row['quantity']); ?></td>
          <td><?php echo htmlspecialchars($row['transaction_date']); ?></td>
          <td><?php echo htmlspecialchars($row['description']); ?></td>
          <td>
            <a href="edit.php?id=<?php echo $row['id']; ?>" class="btn btn-sm btn-primary">Edit</a>
            <a href="delete.php?id=<?php echo $row['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this transaction?');">Delete</a>
          </td>
        </tr>
        <?php endwhile; else: ?>
        <tr><td colspan="6" class="text-center">No transactions found.</td></tr>
        <?php endif; ?>
      </tbody>
    </table>
  </div>
  <?php if (isset($_GET['deleted'])): ?>
    <div class="alert alert-<?php echo $_GET['deleted'] == 1 ? 'success' : 'danger'; ?> mt-3">
      <?php echo $_GET['deleted'] == 1 ? 'Transaction deleted successfully!' : 'Error deleting transaction.'; ?>
    </div>
  <?php endif; ?>
</div>
<script>
$(document).ready(function() {
    $('#transactionsTable').DataTable();
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
