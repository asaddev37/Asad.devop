<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';

// Filtering logic
$userFilter = isset($_GET['user']) ? trim($_GET['user']) : '';
$actionFilter = isset($_GET['action']) ? trim($_GET['action']) : '';
$dateFrom = isset($_GET['date_from']) ? trim($_GET['date_from']) : '';
$dateTo = isset($_GET['date_to']) ? trim($_GET['date_to']) : '';

// Build query with filters
$sql = "SELECT AuditLogs.id, Users.username, Users.role, AuditLogs.action, AuditLogs.timestamp, AuditLogs.details FROM AuditLogs JOIN Users ON AuditLogs.user_id = Users.id WHERE 1=1";
$params = [];
$types = '';
if ($userFilter !== '') {
    $sql .= " AND Users.username LIKE ?";
    $params[] = "%$userFilter%";
    $types .= 's';
}
if ($actionFilter !== '') {
    $sql .= " AND AuditLogs.action LIKE ?";
    $params[] = "%$actionFilter%";
    $types .= 's';
}
if ($dateFrom !== '') {
    $sql .= " AND AuditLogs.timestamp >= ?";
    $params[] = $dateFrom . ' 00:00:00';
    $types .= 's';
}
if ($dateTo !== '') {
    $sql .= " AND AuditLogs.timestamp <= ?";
    $params[] = $dateTo . ' 23:59:59';
    $types .= 's';
}
$sql .= " ORDER BY AuditLogs.timestamp DESC";

$stmt = $conn->prepare($sql);
if ($params) {
    $stmt->bind_param($types, ...$params);
}
$stmt->execute();
$result = $stmt->get_result();
$error = '';
if (!$result) {
    $error = 'Error fetching audit logs: ' . $conn->error;
}
// Fetch all usernames for filter dropdown
$usersRes = $conn->query("SELECT username FROM Users ORDER BY username");
$allUsers = $usersRes ? $usersRes->fetch_all(MYSQLI_ASSOC) : [];
// Fetch all distinct actions for filter dropdown
$actionsRes = $conn->query("SELECT DISTINCT action FROM AuditLogs ORDER BY action");
$allActions = $actionsRes ? $actionsRes->fetch_all(MYSQLI_ASSOC) : [];
?>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
  <div class="container-fluid">
    <a class="navbar-brand" href="../index.php">Dashboard</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item"><a class="nav-link" href="../users/index.php">User Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../inventory/index.php">Inventory Management</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">Supplier Management</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Audit Logs</a></li>
        <li class="nav-item"><a class="nav-link" href="../settings/index.php">Settings</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Audit Logs</h2>
    <a href="export.php" class="btn btn-info">Export Logs</a>
  </div>
  <form class="row g-3 mb-4" method="get" action="">
    <div class="col-md-3">
      <label for="user" class="form-label">User</label>
      <select class="form-select" id="user" name="user">
        <option value="">All Users</option>
        <?php foreach ($allUsers as $u): ?>
          <option value="<?php echo htmlspecialchars($u['username']); ?>" <?php if ($userFilter === $u['username']) echo 'selected'; ?>><?php echo htmlspecialchars($u['username']); ?></option>
        <?php endforeach; ?>
      </select>
    </div>
    <div class="col-md-3">
      <label for="action" class="form-label">Action</label>
      <select class="form-select" id="action" name="action">
        <option value="">All Actions</option>
        <?php foreach ($allActions as $a): $actionVal = $a['action']; ?>
          <option value="<?php echo htmlspecialchars($actionVal); ?>" <?php if ($actionFilter === $actionVal) echo 'selected'; ?>><?php echo htmlspecialchars($actionVal); ?></option>
        <?php endforeach; ?>
      </select>
    </div>
    <div class="col-md-2">
      <label for="date_from" class="form-label">From</label>
      <input type="date" class="form-control" id="date_from" name="date_from" value="<?php echo htmlspecialchars($dateFrom); ?>">
    </div>
    <div class="col-md-2">
      <label for="date_to" class="form-label">To</label>
      <input type="date" class="form-control" id="date_to" name="date_to" value="<?php echo htmlspecialchars($dateTo); ?>">
    </div>
    <div class="col-md-2 d-flex align-items-end">
      <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search"></i> Filter</button>
    </div>
  </form>
  <?php if ($error): ?>
    <div class="alert alert-danger"><?php echo $error; ?></div>
  <?php endif; ?>
  <table class="table table-bordered table-striped">
    <thead class="table-dark">
      <tr>
        <th>ID</th>
        <th>User</th>
        <th>Role</th>
        <th>Action</th>
        <th>Timestamp</th>
        <th>Details</th>
      </tr>
    </thead>
    <tbody>
      <?php if ($result && $result->num_rows > 0): while ($log = $result->fetch_assoc()): ?>
      <tr>
        <td><?php echo $log['id']; ?></td>
        <td><?php echo htmlspecialchars($log['username']); ?></td>
        <td><?php echo htmlspecialchars($log['role']); ?></td>
        <td><?php echo htmlspecialchars($log['action']); ?></td>
        <td><?php echo $log['timestamp']; ?></td>
        <td><?php echo htmlspecialchars($log['details']); ?></td>
      </tr>
      <?php endwhile; else: ?>
      <tr><td colspan="6" class="text-center">No audit logs found.</td></tr>
      <?php endif; ?>
    </tbody>
  </table>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../users/index.php" class="btn btn-outline-light btn-sm me-2">Users</a>
      <a href="../inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">Suppliers</a>
      <a href="index.php" class="btn btn-outline-light btn-sm me-2">Audit Logs</a>
      <a href="../settings/index.php" class="btn btn-outline-light btn-sm">Settings</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
