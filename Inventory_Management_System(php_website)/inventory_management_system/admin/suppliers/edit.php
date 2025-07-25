<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';

$id = $_GET['id'] ?? null;
if (!$id) {
    header('Location: index.php');
    exit;
}

// Fetch supplier data
$stmt = $conn->prepare('SELECT name, contact_info, address FROM Suppliers WHERE id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();
$stmt->bind_result($name, $contact_info, $address);
if (!$stmt->fetch()) {
    $stmt->close();
    header('Location: index.php');
    exit;
}
$stmt->close();

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $contact_info = trim($_POST['contact_info'] ?? '');
    $address = trim($_POST['address'] ?? '');
    if ($name) {
        $stmt = $conn->prepare('UPDATE Suppliers SET name=?, contact_info=?, address=? WHERE id=?');
        $stmt->bind_param('sssi', $name, $contact_info, $address, $id);
        if ($stmt->execute()) {
            include_once '../../includes/functions.php';
            logActivity($_SESSION['user_id'], 'Edit Supplier', 'Edited supplier ID: ' . $id);
            header('Location: index.php');
            exit;
        } else {
            $error = 'Error updating supplier: ' . $stmt->error;
        }
        $stmt->close();
    } else {
        $error = 'Supplier name is required!';
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
        <li class="nav-item"><a class="nav-link" href="../inventory/index.php">Inventory Management</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Supplier Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../audit-logs/index.php">Audit Logs</a></li>
        <li class="nav-item"><a class="nav-link" href="../settings/index.php">Settings</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5">
  <h2>Edit Supplier</h2>
  <?php if ($error): ?><div class="alert alert-danger"><?php echo $error; ?></div><?php endif; ?>
  <form method="post" action="">
    <div class="mb-3">
      <label for="name" class="form-label">Supplier Name</label>
      <input type="text" class="form-control" id="name" name="name" value="<?php echo htmlspecialchars($name); ?>" required>
    </div>
    <div class="mb-3">
      <label for="contact_info" class="form-label">Contact Info</label>
      <input type="text" class="form-control" id="contact_info" name="contact_info" value="<?php echo htmlspecialchars($contact_info); ?>">
    </div>
    <div class="mb-3">
      <label for="address" class="form-label">Address</label>
      <textarea class="form-control" id="address" name="address"><?php echo htmlspecialchars($address); ?></textarea>
    </div>
    <button type="submit" class="btn btn-primary">Update Supplier</button>
    <a href="index.php" class="btn btn-secondary">Cancel</a>
  </form>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../users/index.php" class="btn btn-outline-light btn-sm me-2">Users</a>
      <a href="../inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="index.php" class="btn btn-outline-light btn-sm me-2">Suppliers</a>
      <a href="../audit-logs/index.php" class="btn btn-outline-light btn-sm me-2">Audit Logs</a>
      <a href="../settings/index.php" class="btn btn-outline-light btn-sm">Settings</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<?php // No need to include footer.php since custom footer is used above ?>
