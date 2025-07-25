<?php
// staff/requests/create.php
// This page allows staff to send a request to the manager.

require_once '../../includes/config.php';
require_once '../../includes/functions.php';
session_start();

// Check if user is logged in and is staff
if (!isset($_SESSION['user_id']) || strtolower($_SESSION['role']) !== 'staff') {
    header('Location: ../../auth/login.php');
    exit();
}

// Fetch all managers for dropdown
$managers = $conn->query("SELECT id, full_name, username FROM Users WHERE role = 'Manager' ORDER BY full_name ASC");

$message = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $type = trim($_POST['type']);
    $details = trim($_POST['details']);
    $manager_id = intval($_POST['manager_id']);
    $staff_id = $_SESSION['user_id'];
    if ($type && $details && $manager_id) {
        $stmt = $conn->prepare("INSERT INTO requests (staff_id, manager_id, type, details, status, created_at) VALUES (?, ?, ?, ?, 'Pending', NOW())");
        $stmt->bind_param('iiss', $staff_id, $manager_id, $type, $details);
        if ($stmt->execute()) {
            $message = '<div class="alert alert-success">Request sent successfully!</div>';
            logActivity($staff_id, 'Send Request', 'Sent request to manager ID: ' . $manager_id . ', type: ' . $type);
        } else {
            $message = '<div class="alert alert-danger">Error sending request.</div>';
        }
        $stmt->close();
    } else {
        $message = '<div class="alert alert-warning">Please fill in all fields.</div>';
    }
}

// Fetch request history for this staff
$staff_id = $_SESSION['user_id'];
$history = $conn->query("SELECT r.*, u.full_name AS manager_name FROM requests r LEFT JOIN Users u ON r.manager_id = u.id WHERE r.staff_id = $staff_id ORDER BY r.created_at DESC");

include '../../includes/header.php';
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
        <li class="nav-item"><a class="nav-link" href="../transactions/index.php">Manage Transactions</a></li>
        <li class="nav-item"><a class="nav-link" href="../suppliers/index.php">View Suppliers</a></li>
        <li class="nav-item"><a class="nav-link active" href="create.php">Send Request to Manager</a></li>
        <li class="nav-item"><a class="nav-link" href="../view-transactions.php">View Transactions</a></li>
      </ul>
      <span class="navbar-text me-3">Welcome, <?php echo htmlspecialchars($_SESSION['username']); ?></span>
      <a href="../../auth/logout.php" class="btn btn-outline-light">Logout</a>
    </div>
  </div>
</nav>
<div class="container mt-5 mb-4 flex-grow-1">
    <h2>Send Request to Manager</h2>
    <?= $message ?>
    <form method="post" class="mt-3 mb-5">
        <div class="row g-3 align-items-end">
            <div class="col-md-3">
                <label for="manager_id" class="form-label">Choose Manager</label>
                <select name="manager_id" id="manager_id" class="form-select" required>
                    <option value="">Select Manager</option>
                    <?php if ($managers && $managers->num_rows > 0): while($m = $managers->fetch_assoc()): ?>
                        <option value="<?php echo $m['id']; ?>"><?php echo htmlspecialchars($m['full_name'] ?: $m['username']); ?></option>
                    <?php endwhile; endif; ?>
                </select>
            </div>
            <div class="col-md-3">
                <label for="type" class="form-label">Request Type</label>
                <select name="type" id="type" class="form-select" required>
                    <option value="">Select Type</option>
                    <option value="Add Inventory">Add Inventory</option>
                    <option value="Remove Inventory">Remove Inventory</option>
                    <option value="Update Inventory">Update Inventory</option>
                    <option value="Request Purchase">Request Purchase</option>
                    <option value="Report Issue">Report Issue</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            <div class="col-md-6">
                <label for="details" class="form-label">Details</label>
                <textarea name="details" id="details" class="form-control" rows="2" required></textarea>
            </div>
        </div>
        <div class="mt-3 text-end">
            <button type="submit" class="btn btn-primary">Send Request</button>
        </div>
    </form>
    <h4 class="mb-3">Your Request History</h4>
    <div class="table-responsive">
        <table class="table table-striped table-bordered">
            <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Manager</th>
                    <th>Type</th>
                    <th>Details</th>
                    <th>Status</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                <?php if ($history && $history->num_rows > 0): $i = 1; while($row = $history->fetch_assoc()): ?>
                <tr>
                    <td><?php echo $i++; ?></td>
                    <td><?php echo htmlspecialchars($row['manager_name']); ?></td>
                    <td><?php echo htmlspecialchars($row['type']); ?></td>
                    <td><?php echo htmlspecialchars($row['details']); ?></td>
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
                    <td><?php echo htmlspecialchars($row['created_at']); ?></td>
                </tr>
                <?php endwhile; else: ?>
                <tr><td colspan="6" class="text-center">No requests found.</td></tr>
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
      <a href="../transactions/index.php" class="btn btn-outline-light btn-sm me-2">Manage Transactions</a>
      <a href="../suppliers/index.php" class="btn btn-outline-light btn-sm me-2">View Suppliers</a>
      <a href="create.php" class="btn btn-outline-light btn-sm me-2">Send Request</a>
      <a href="../view-transactions.php" class="btn btn-outline-light btn-sm">View Transactions</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by Your Team</div>
  </div>
</footer>
</div>
