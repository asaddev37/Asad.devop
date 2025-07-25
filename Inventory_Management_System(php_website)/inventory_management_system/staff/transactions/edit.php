<?php
session_start();
if (!isset($_SESSION['user_id']) || $_SESSION['role'] !== 'Staff') {
    header('Location: ../../auth/login.php');
    exit;
}
include '../../includes/config.php';
include '../../includes/header.php';
include '../../includes/functions.php';

$id = intval($_GET['id'] ?? 0);
$user_id = $_SESSION['user_id'];

// Fetch transaction
$stmt = $conn->prepare("SELECT * FROM Transactions WHERE id = ? AND user_id = ?");
$stmt->bind_param('ii', $id, $user_id);
$stmt->execute();
$result = $stmt->get_result();
$transaction = $result->fetch_assoc();
$stmt->close();
if (!$transaction) {
    echo '<div class="alert alert-danger">Transaction not found.</div>';
    include '../../includes/footer.php';
    exit;
}

// Fetch inventory for dropdown
$inventory = $conn->query("SELECT id, name FROM Inventory ORDER BY name ASC");

$edit_error = '';
$edit_success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $item_id = intval($_POST['item_id']);
    $type = $_POST['type'];
    $quantity = intval($_POST['quantity']);
    $description = trim($_POST['description']);
    if ($item_id && $type && $quantity > 0) {
        $stmt = $conn->prepare("UPDATE Transactions SET item_id=?, type=?, quantity=?, description=? WHERE id=? AND user_id=?");
        $stmt->bind_param('isisii', $item_id, $type, $quantity, $description, $id, $user_id);
        if ($stmt->execute()) {
            $edit_success = 'Transaction updated successfully!';
            logActivity($user_id, 'Edit Transaction', 'Edited transaction ID: ' . $id . ', item ID: ' . $item_id . ', type: ' . $type . ', qty: ' . $quantity);
        } else {
            $edit_error = 'Error updating transaction.';
        }
        $stmt->close();
    } else {
        $edit_error = 'Please fill all fields and enter a valid quantity.';
    }
}
?>
<div class="container mt-5 mb-4">
  <h2>Edit Transaction</h2>
  <?php if ($edit_success): ?><div class="alert alert-success"><?php echo $edit_success; ?></div><?php endif; ?>
  <?php if ($edit_error): ?><div class="alert alert-danger"><?php echo $edit_error; ?></div><?php endif; ?>
  <form method="post">
    <div class="row g-3 align-items-end">
      <div class="col-md-4">
        <label for="item_id" class="form-label">Inventory Item</label>
        <select name="item_id" id="item_id" class="form-select" required>
          <option value="">Select Item</option>
          <?php if ($inventory && $inventory->num_rows > 0): while($inv = $inventory->fetch_assoc()): ?>
            <option value="<?php echo $inv['id']; ?>" <?php if ($transaction['item_id'] == $inv['id']) echo 'selected'; ?>><?php echo htmlspecialchars($inv['name']); ?></option>
          <?php endwhile; endif; ?>
        </select>
      </div>
      <div class="col-md-2">
        <label for="type" class="form-label">Type</label>
        <select name="type" id="type" class="form-select" required>
          <option value="Add" <?php if ($transaction['type'] == 'Add') echo 'selected'; ?>>Add</option>
          <option value="Remove" <?php if ($transaction['type'] == 'Remove') echo 'selected'; ?>>Remove</option>
          <option value="Update" <?php if ($transaction['type'] == 'Update') echo 'selected'; ?>>Update</option>
        </select>
      </div>
      <div class="col-md-2">
        <label for="quantity" class="form-label">Quantity</label>
        <input type="number" name="quantity" id="quantity" class="form-control" min="1" value="<?php echo htmlspecialchars($transaction['quantity']); ?>" required>
      </div>
      <div class="col-md-4">
        <label for="description" class="form-label">Description</label>
        <input type="text" name="description" id="description" class="form-control" value="<?php echo htmlspecialchars($transaction['description']); ?>">
      </div>
    </div>
    <div class="mt-3 text-end">
      <button type="submit" class="btn btn-primary">Update Transaction</button>
      <a href="index.php" class="btn btn-secondary">Back</a>
    </div>
  </form>
</div>
<?php include '../../includes/footer.php'; ?>
