<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';
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
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">Supplier Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../audit-logs/index.php">Audit Logs</a></li>
        <li class="nav-item"><a class="nav-link" href="../settings/index.php">Settings</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>

<?php
$id = $_GET['id'] ?? null;
if (!$id) {
    header('Location: index.php');
    exit;
}

$error = '';
$success = '';
$stmt = $conn->prepare('SELECT username, email, full_name, role FROM Users WHERE id = ?');
$stmt->bind_param('i', $id);
$stmt->execute();
$stmt->bind_result($username, $email, $full_name, $role);
if (!$stmt->fetch()) {
    $stmt->close();
    header('Location: index.php');
    exit;
}
$stmt->close();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $full_name = trim($_POST['full_name'] ?? '');
    $role = $_POST['role'] ?? '';
    if ($username && $email && $full_name && $role) {
        if (!preg_match('/\.com$/i', $email)) {
            $error = 'Email must end with .com';
        } else {
            $stmt = $conn->prepare('UPDATE Users SET username=?, email=?, full_name=?, role=? WHERE id=?');
            $stmt->bind_param('ssssi', $username, $email, $full_name, $role, $id);
            if ($stmt->execute()) {
                include_once '../../includes/functions.php';
                logActivity($_SESSION['user_id'], 'Edit User', 'Edited user ID: ' . $id);
                $success = 'User updated successfully!';
            } else {
                $error = 'Error updating user: ' . $stmt->error;
            }
            $stmt->close();
        }
    } else {
        $error = 'All fields are required!';
    }
}
?>
<div class="container mt-5">
  <h2>Edit User</h2>
  <?php if ($error): ?><div class="alert alert-danger"><?php echo $error; ?></div><?php endif; ?>
  <?php if ($success): ?><div class="alert alert-success"><?php echo $success; ?></div><?php endif; ?>
  <form method="post" action="">
    <div class="mb-3">
      <label for="username" class="form-label">Username</label>
      <input type="text" class="form-control" id="username" name="username" value="<?php echo htmlspecialchars($username); ?>" required>
    </div>
    <div class="mb-3">
      <label for="email" class="form-label">Email</label>
      <input type="email" class="form-control" id="email" name="email" value="<?php echo htmlspecialchars($email); ?>" required>
    </div>
    <div class="mb-3">
      <label for="full_name" class="form-label">Full Name</label>
      <input type="text" class="form-control" id="full_name" name="full_name" value="<?php echo htmlspecialchars($full_name); ?>" required>
    </div>
    <div class="mb-3">
      <label for="role" class="form-label">Role</label>
      <select class="form-select" id="role" name="role" required>
        <option value="Admin" <?php if ($role=='Admin') echo 'selected'; ?>>Admin</option>
        <option value="Manager" <?php if ($role=='Manager') echo 'selected'; ?>>Manager</option>
        <option value="Staff" <?php if ($role=='Staff') echo 'selected'; ?>>Staff</option>
      </select>
    </div>
    <button type="submit" class="btn btn-primary">Update User</button>
    <a href="index.php" class="btn btn-secondary">Cancel</a>
  </form>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../users/index.php" class="btn btn-outline-light btn-sm me-2">Users</a>
      <a href="../inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">Suppliers</a>
      <a href="../audit-logs/index.php" class="btn btn-outline-light btn-sm me-2">Audit Logs</a>
      <a href="../settings/index.php" class="btn btn-outline-light btn-sm">Settings</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
