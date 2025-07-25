<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';

// Fetch suppliers for dropdown
$suppliers = $conn->query("SELECT id, name FROM Suppliers ORDER BY name ASC");
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $category = trim($_POST['category'] ?? '');
    $quantity = intval($_POST['quantity'] ?? 0);
    $unit_price = floatval($_POST['unit_price'] ?? 0);
    $supplier_id = $_POST['supplier_id'] !== '' ? $_POST['supplier_id'] : null;
    if ($name && $category && $quantity >= 0 && $unit_price >= 0) {
        $stmt = $conn->prepare('INSERT INTO Inventory (name, category, quantity, unit_price, supplier_id) VALUES (?, ?, ?, ?, ?)');
        // If supplier_id is null, bind as null (i for int, but null is allowed)
        if ($supplier_id === null) {
            $stmt->bind_param('ssidi', $name, $category, $quantity, $unit_price, $supplier_id);
        } else {
            $supplier_id = (int)$supplier_id;
            $stmt->bind_param('ssidi', $name, $category, $quantity, $unit_price, $supplier_id);
        }
        if ($stmt->execute()) {
            include_once '../../includes/functions.php';
            logActivity($_SESSION['user_id'], 'Add Inventory', 'Added inventory item: ' . $name);
            header('Location: index.php');
            exit;
        } else {
            $error = 'Error adding item: ' . $stmt->error;
        }
        $stmt->close();
    } else {
        $error = 'All fields are required and must be valid!';
    }
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
  <h2>Add Inventory Item</h2>
  <?php if ($error): ?><div class="alert alert-danger"><?php echo $error; ?></div><?php endif; ?>
  <form method="post" action="">
    <div class="mb-3">
      <label for="name" class="form-label">Item Name</label>
      <input type="text" class="form-control" id="name" name="name" required>
    </div>
    <div class="mb-3">
      <label for="category" class="form-label">Category</label>
      <input type="text" class="form-control" id="category" name="category" required>
    </div>
    <div class="mb-3">
      <label for="quantity" class="form-label">Quantity</label>
      <input type="number" class="form-control" id="quantity" name="quantity" min="0" required>
    </div>
    <div class="mb-3">
      <label for="unit_price" class="form-label">Unit Price</label>
      <input type="number" step="0.01" class="form-control" id="unit_price" name="unit_price" min="0" required>
    </div>
    <div class="mb-3">
      <label for="supplier_id" class="form-label">Supplier</label>
      <select class="form-select" id="supplier_id" name="supplier_id">
        <option value="">None</option>
        <?php while ($row = $suppliers->fetch_assoc()): ?>
          <option value="<?php echo $row['id']; ?>"><?php echo htmlspecialchars($row['name']); ?></option>
        <?php endwhile; ?>
      </select>
    </div>
    <button type="submit" class="btn btn-success">Add Item</button>
    <a href="index.php" class="btn btn-secondary">Cancel</a>
  </form>
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
