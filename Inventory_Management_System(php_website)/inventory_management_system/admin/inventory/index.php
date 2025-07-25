<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
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
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container-fluid">
    <a class="navbar-brand" href="../index.php">Admin Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link" href="../users/index.php">User Management</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Inventory Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">Supplier Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../audit-logs/index.php">Audit Logs</a></li>
        <li class="nav-item"><a class="nav-link" href="../settings/index.php">Settings</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Inventory Management</h2>
    <a href="create.php" class="btn btn-success">Add Item</a>
  </div>
  <?php if ($error): ?>
    <div class="alert alert-danger"><?php echo $error; ?></div>
  <?php endif; ?>
  <table class="table table-bordered table-striped">
    <thead class="table-dark">
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Category</th>
        <th>Quantity</th>
        <th>Unit Price</th>
        <th>Supplier</th>
        <th>Last Updated</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <?php if ($result): while ($item = $result->fetch_assoc()): ?>
      <tr>
        <td><?php echo $item['id']; ?></td>
        <td><?php echo htmlspecialchars($item['name']); ?></td>
        <td><?php echo htmlspecialchars($item['category']); ?></td>
        <td><?php echo $item['quantity']; ?></td>
        <td><?php echo number_format($item['unit_price'], 2); ?></td>
        <td><?php echo htmlspecialchars($item['supplier_name'] ?? ''); ?></td>
        <td><?php echo $item['last_updated']; ?></td>
        <td>
          <a href="edit.php?id=<?php echo $item['id']; ?>" class="btn btn-sm btn-primary">Edit</a>
          <a href="delete.php?id=<?php echo $item['id']; ?>" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?');">Delete</a>
        </td>
      </tr>
      <?php endwhile; endif; ?>
    </tbody>
  </table>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../users/index.php" class="btn btn-outline-light btn-sm me-2">Users</a>
      <a href="index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">Suppliers</a>
      <a href="../audit-logs/index.php" class="btn btn-outline-light btn-sm me-2">Audit Logs</a>
      <a href="../settings/index.php" class="btn btn-outline-light btn-sm">Settings</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<?php // No need to include footer.php since custom footer is used above ?>
