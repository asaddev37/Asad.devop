<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Admin') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/functions.php';
include '../../includes/header.php';

// Handle update
$error = '';
$success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    foreach ($_POST['settings'] as $key => $value) {
        $stmt = $conn->prepare('UPDATE settings SET param_value=? WHERE param_key=?');
        $stmt->bind_param('ss', $value, $key);
        if ($stmt->execute()) {
            $success = 'Settings updated successfully!';
            logActivity($_SESSION['user_id'], 'Update Setting', 'Updated setting: ' . $key . ' = ' . $value);
        } else {
            $error = 'Error updating settings: ' . $stmt->error;
        }
        $stmt->close();
    }
}
// Add new setting
if (isset($_POST['new_key']) && isset($_POST['new_value']) && $_POST['new_key'] !== '') {
    $new_key = trim($_POST['new_key']);
    $new_value = trim($_POST['new_value']);
    $stmt = $conn->prepare('INSERT INTO settings (param_key, param_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE param_value=VALUES(param_value)');
    $stmt->bind_param('ss', $new_key, $new_value);
    if ($stmt->execute()) {
        $success = 'New setting added or updated!';
        logActivity($_SESSION['user_id'], 'Add/Update Setting', 'Added/Updated setting: ' . $new_key . ' = ' . $new_value);
    } else {
        $error = 'Error adding setting: ' . $stmt->error;
    }
    $stmt->close();
}
// Handle delete setting
if (isset($_POST['delete_setting']) && isset($_POST['delete_key']) && $_POST['delete_key'] !== '') {
    $delete_key = $_POST['delete_key'];
    $stmt = $conn->prepare('DELETE FROM settings WHERE param_key=?');
    $stmt->bind_param('s', $delete_key);
    if ($stmt->execute()) {
        $success = 'Setting deleted!';
        logActivity($_SESSION['user_id'], 'Delete Setting', 'Deleted setting: ' . $delete_key);
    } else {
        $error = 'Error deleting setting: ' . $stmt->error;
    }
    $stmt->close();
    // Refresh settings after delete
    header('Location: index.php');
    exit;
}
// Fetch all settings
$settings = [];
$result = $conn->query('SELECT param_key, param_value FROM settings');
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $settings[$row['param_key']] = $row['param_value'];
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
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">Supplier Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../audit-logs/index.php">Audit Logs</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Settings</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5">
  <h2>System Settings</h2>
  <?php if ($error): ?><div class="alert alert-danger"><?php echo $error; ?></div><?php endif; ?>
  <?php if ($success): ?><div class="alert alert-success"><?php echo $success; ?></div><?php endif; ?>
  <form method="post" action="">
    <div class="row">
      <?php foreach ($settings as $key => $value): ?>
      <div class="col-md-6 mb-3">
        <label class="form-label" for="setting_<?php echo $key; ?>"><?php echo ucwords(str_replace('_', ' ', $key)); ?></label>
        <input type="text" class="form-control" id="setting_<?php echo $key; ?>" name="settings[<?php echo $key; ?>]" value="<?php echo htmlspecialchars($value); ?>">
      </div>
      <?php endforeach; ?>
    </div>
    <button type="submit" class="btn btn-primary">Save Settings</button>
  </form>
  <hr>
  <h4 class="mt-4">Add New Setting</h4>
  <form method="post" action="">
    <div class="row">
      <div class="col-md-4 mb-3">
        <input type="text" class="form-control" name="new_key" placeholder="Setting Key (e.g. site_name)" required>
      </div>
      <div class="col-md-4 mb-3">
        <input type="text" class="form-control" name="new_value" placeholder="Setting Value" required>
      </div>
      <div class="col-md-4 mb-3">
        <button type="submit" class="btn btn-success">Add Setting</button>
      </div>
    </div>
  </form>
  <hr>
  <h4 class="mt-4">Delete Setting</h4>
  <form method="post" action="">
    <div class="row">
      <div class="col-md-6 mb-3">
        <select class="form-select" name="delete_key" required>
          <option value="">Select setting to delete</option>
          <?php foreach ($settings as $key => $value): ?>
            <option value="<?php echo $key; ?>"><?php echo $key; ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div class="col-md-6 mb-3">
        <button type="submit" name="delete_setting" class="btn btn-danger">Delete Setting</button>
      </div>
    </div>
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
      <a href="index.php" class="btn btn-outline-light btn-sm">Settings</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<?php // No need to include footer.php since custom footer is used above ?>
