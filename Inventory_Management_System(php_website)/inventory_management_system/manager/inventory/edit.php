<?php
session_start();
if (!isset($_SESSION['user_id']) || strtolower($_SESSION['role']) !== 'manager') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';
include '../../includes/functions.php';

$id = intval($_GET['id'] ?? 0);
if (!$id) {
    echo '<div class="alert alert-danger">Invalid inventory item.</div>';
    include '../../includes/footer.php';
    exit;
}
// Fetch item
$stmt = $conn->prepare("SELECT * FROM Inventory WHERE id = ?");
$stmt->bind_param('i', $id);
$stmt->execute();
$item = $stmt->get_result()->fetch_assoc();
$stmt->close();
if (!$item) {
    echo '<div class="alert alert-danger">Item not found.</div>';
    include '../../includes/footer.php';
    exit;
}
// Fetch suppliers for dropdown
$suppliers = $conn->query("SELECT id, name FROM Suppliers ORDER BY name ASC");
$edit_error = '';
$edit_success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name']);
    $category = trim($_POST['category']);
    $quantity = intval($_POST['quantity']);
    $unit_price = floatval($_POST['unit_price']);
    $supplier_id = intval($_POST['supplier_id']) ?: null;
    if ($name && $quantity >= 0 && $unit_price >= 0) {
        $stmt = $conn->prepare("UPDATE Inventory SET name=?, category=?, quantity=?, unit_price=?, supplier_id=? WHERE id=?");
        $stmt->bind_param('ssidii', $name, $category, $quantity, $unit_price, $supplier_id, $id);
        if ($stmt->execute()) {
            $edit_success = 'Item updated successfully!';
            logActivity($_SESSION['user_id'], 'Edit Inventory', 'Edited inventory item ID: ' . $id);
        } else {
            $edit_error = 'Error updating item.';
        }
        $stmt->close();
    } else {
        $edit_error = 'Please fill all required fields.';
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
        <li class="nav-item"><a class="nav-link" href="index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link" href="../reports/index.php">Reports</a></li>
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
  <h2>Edit Inventory Item</h2>
  <?php if ($edit_success): ?><div class="alert alert-success"><?php echo $edit_success; ?></div><?php endif; ?>
  <?php if ($edit_error): ?><div class="alert alert-danger"><?php echo $edit_error; ?></div><?php endif; ?>
  <form method="post">
    <div class="row g-3 align-items-end">
      <div class="col-md-4">
        <label for="name" class="form-label">Name</label>
        <input type="text" name="name" id="name" class="form-control" value="<?php echo htmlspecialchars($item['name']); ?>" required>
      </div>
      <div class="col-md-3">
        <label for="category" class="form-label">Category</label>
        <input type="text" name="category" id="category" class="form-control" value="<?php echo htmlspecialchars($item['category']); ?>">
      </div>
      <div class="col-md-2">
        <label for="quantity" class="form-label">Quantity</label>
        <input type="number" name="quantity" id="quantity" class="form-control" min="0" value="<?php echo htmlspecialchars($item['quantity']); ?>" required>
      </div>
      <div class="col-md-2">
        <label for="unit_price" class="form-label">Unit Price</label>
        <input type="number" step="0.01" name="unit_price" id="unit_price" class="form-control" min="0" value="<?php echo htmlspecialchars($item['unit_price']); ?>" required>
      </div>
      <div class="col-md-3">
        <label for="supplier_id" class="form-label">Supplier</label>
        <select name="supplier_id" id="supplier_id" class="form-select">
          <option value="">None</option>
          <?php if ($suppliers && $suppliers->num_rows > 0): while($s = $suppliers->fetch_assoc()): ?>
            <option value="<?php echo $s['id']; ?>" <?php if ($item['supplier_id'] == $s['id']) echo 'selected'; ?>><?php echo htmlspecialchars($s['name']); ?></option>
          <?php endwhile; endif; ?>
        </select>
      </div>
    </div>
    <div class="mt-3 text-end">
      <button type="submit" class="btn btn-primary">Update Item</button>
      <a href="index.php" class="btn btn-secondary">Back</a>
    </div>
  </form>
</div>
<?php include '../../includes/footer.php'; ?>
</div>
