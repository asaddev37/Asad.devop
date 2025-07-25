<?php
// manager/requests/index.php
// This page will display requests sent from staff to the manager.

require_once '../../includes/config.php';
require_once '../../includes/functions.php';
session_start();

// Check if user is logged in and is a manager
if (!isset($_SESSION['user_id']) || strtolower($_SESSION['role']) !== 'manager') {
    header('Location: ../../auth/login.php');
    exit();
}
$manager_id = $_SESSION['user_id'];

// Handle status update
$status_message = '';
if (isset($_POST['update_status'], $_POST['request_id'], $_POST['status'])) {
    $request_id = intval($_POST['request_id']);
    $status = $_POST['status'];
    if (in_array($status, ['Pending', 'Approved', 'Rejected'])) {
        $stmt = $conn->prepare("UPDATE requests SET status=? WHERE id=? AND manager_id=?");
        $stmt->bind_param('sii', $status, $request_id, $manager_id);
        if ($stmt->execute()) {
            logActivity($manager_id, 'Update Request Status', 'Request ID: ' . $request_id . ' set to ' . $status);
            $status_message = '<div class=\"alert alert-success\">Status updated!</div>';
        } else {
            $status_message = '<div class=\"alert alert-danger\">Error updating status.</div>';
        }
        $stmt->close();
    }
}
// Fetch requests assigned to this manager
$sql = "SELECT r.*, s.full_name AS staff_name FROM requests r JOIN Users s ON r.staff_id = s.id WHERE r.manager_id = $manager_id ORDER BY r.created_at DESC";
$result = $conn->query($sql);

include '../../includes/header.php';
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
        <li class="nav-item"><a class="nav-link" href="../inventory/index.php">Inventory</a></li>
        <li class="nav-item"><a class="nav-link" href="../reports/index.php">Reports</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">Suppliers</a></li>
        <li class="nav-item"><a class="nav-link" href="../transactions/index.php">Transactions</a></li>
        <li class="nav-item"><a class="nav-link active" href="index.php">Requests from Staff</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5 mb-4 flex-grow-1">
    <h2>Requests from Staff</h2>
    <?= $status_message ?>
    <div class="table-responsive">
    <table class="table table-bordered table-hover mt-3">
        <thead class="table-dark">
            <tr>
                <th>#</th>
                <th>Staff Name</th>
                <th>Request Type</th>
                <th>Details</th>
                <th>Status</th>
                <th>Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <?php if ($result && $result->num_rows > 0): $i = 1; while($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?= $i++ ?></td>
                <td><?= htmlspecialchars($row['staff_name']) ?></td>
                <td><?= htmlspecialchars($row['type']) ?></td>
                <td><?= htmlspecialchars($row['details']) ?></td>
                <td>
                    <?php if ($row['status'] == 'Pending'): ?>
                        <span class="badge bg-warning text-dark">Pending</span>
                    <?php elseif ($row['status'] == 'Approved'): ?>
                        <span class="badge bg-success">Approved</span>
                    <?php elseif ($row['status'] == 'Rejected'): ?>
                        <span class="badge bg-danger">Rejected</span>
                    <?php else: ?>
                        <span class="badge bg-secondary">Unknown</span>
                    <?php endif; ?>
                </td>
                <td><?= htmlspecialchars($row['created_at']) ?></td>
                <td>
                  <?php if ($row['status'] == 'Pending'): ?>
                  <form method="post" class="d-flex gap-2 align-items-center">
                    <input type="hidden" name="request_id" value="<?= $row['id'] ?>">
                    <select name="status" class="form-select form-select-sm" required>
                      <option value="">Update Status</option>
                      <option value="Approved">Approve</option>
                      <option value="Rejected">Reject</option>
                    </select>
                    <button type="submit" name="update_status" class="btn btn-sm btn-primary">Update</button>
                  </form>
                  <?php else: ?>
                    <span class="text-muted">No action</span>
                  <?php endif; ?>
                </td>
            </tr>
        <?php endwhile; else: ?>
            <tr><td colspan="7" class="text-center">No requests found.</td></tr>
        <?php endif; ?>
        </tbody>
    </table>
    </div>
</div>
<footer class="bg-dark text-white text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="../index.php" class="btn btn-outline-light btn-sm me-2">Dashboard</a>
      <a href="../inventory/index.php" class="btn btn-outline-light btn-sm me-2">Inventory</a>
      <a href="../reports/index.php" class="btn btn-outline-light btn-sm me-2">Reports</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">Suppliers</a>
      <a href="../transactions/index.php" class="btn btn-outline-light btn-sm me-2">Transactions</a>
      <a href="index.php" class="btn btn-outline-light btn-sm">Requests from Staff</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>

</div>
