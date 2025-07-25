<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Login form (Bootstrap styled)
include '../includes/config.php';
include '../includes/functions.php';
session_start();
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    $role = $_POST['role'] ?? '';
    if ($username && $password && $role) {
        $stmt = $conn->prepare('SELECT id, username, password, role FROM Users WHERE username = ? AND role = ?');
        $stmt->bind_param('ss', $username, $role);
        $stmt->execute();
        $result = $stmt->get_result();
        if ($row = $result->fetch_assoc()) {
            // For default users, allow plain password check for first login
            $default_passwords = [
                'admin' => 'admin123',
                'manager' => 'manager123',
                'staff' => 'staff123'
            ];
            $is_default = isset($default_passwords[$row['username']]) && $password === $default_passwords[$row['username']];
            if (password_verify($password, $row['password']) || $is_default) {
                $_SESSION['user_id'] = $row['id'];
                $_SESSION['role'] = $row['role'];
                $_SESSION['username'] = $row['username'];
                // Log activity
                if (function_exists('logActivity')) {
                    logActivity($row['id'], 'Login', 'User logged in');
                }
                // Redirect by role
                switch ($row['role']) {
                    case 'Admin': header('Location: /php_projects/final_project1/inventory_management_system/admin/index.php'); exit;
                    case 'Manager': header('Location: /php_projects/final_project1/inventory_management_system/manager/index.php'); exit;
                    case 'Staff': header('Location: /php_projects/final_project1/inventory_management_system/staff/index.php'); exit;
                }
            } else {
                $error = 'Invalid username, password, or role.';
            }
        } else {
            $error = 'Invalid username, password, or role.';
        }
        $stmt->close();
    } else {
        $error = 'Please enter username, password, and select role.';
    }
}
include '../includes/header.php';
?>
<link rel="stylesheet" href="../assets/css/global-theme.css">
<div class="container d-flex align-items-center justify-content-center neon-auth-spacing" style="min-height: 80vh; position:relative; z-index:2;">
  <div class="neon-panel w-100 position-relative" style="z-index:2;">
    <div class="neon-anim-outline-panel">
      <svg id="diamond-anim" viewBox="0 0 400 400">
        <defs>
          <linearGradient id="neon-gradient" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="#00fff0"/>
            <stop offset="50%" stop-color="#ff61a6"/>
            <stop offset="100%" stop-color="#00fff0"/>
          </linearGradient>
        </defs>
        <polygon points="200,10 390,200 200,390 10,200" fill="none" stroke="url(#neon-gradient)" stroke-width="3" stroke-dasharray="8 4"/>
      </svg>
    </div>
    <div class="login-title">🧬 Identity Access</div>
    <?php if ($error): ?>
      <div class="neon-alert neon-alert-danger text-center mb-3 animate__animated animate__fadeInDown">
        <i class="bi bi-exclamation-triangle-fill me-2"></i> <?php echo htmlspecialchars($error); ?>
      </div>
    <?php endif; ?>
    <form method="post" action="login.php" autocomplete="off">
      <div class="mb-3">
        <label for="username" class="form-label">Username</label>
        <input type="text" class="form-control" id="username" name="username" required autofocus>
      </div>
      <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <input type="password" class="form-control" id="password" name="password" required>
      </div>
      <div class="mb-3">
        <label for="role" class="form-label">Role</label>
        <select class="form-select" id="role" name="role" required>
          <option value="Admin">Admin</option>
          <option value="Manager">Manager</option>
          <option value="Staff">Staff</option>
        </select>
      </div>
      <button type="submit" class="btn btn-neon w-100">Enter</button>
    </form>
    <a href="signup.php" class="signup-link">Don't have an account? Sign up here</a>
  </div>
</div>
<style>
.neon-alert {
  border-radius: 12px;
  padding: 0.75rem 1.2rem;
  font-size: 1.1rem;
  font-family: 'Orbitron', 'Segoe UI', Arial, sans-serif;
  box-shadow: 0 0 18px #ff61a6, 0 2px 12px #00fff0;
  background: linear-gradient(90deg, #23243a 0%, #ff61a6 100%);
  color: #fff;
  text-shadow: 0 0 8px #00fff0, 0 0 2px #23243a;
  border: 2px solid #ff61a6;
  margin-bottom: 1rem;
}
.neon-alert-danger { border-color: #ff61a6; background: linear-gradient(90deg, #23243a 0%, #ff61a6 100%); }
.neon-panel.position-relative { position: relative; }
.neon-anim-outline-panel {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 102%;
  height: 102%;
  transform: translate(-50%, -50%);
  pointer-events: none;
  z-index: 1;
}
.neon-anim-outline-panel svg {
  width: 100%;
  height: 100%;
}
.neon-anim-outline-panel svg polygon {
  filter: drop-shadow(0 0 12px #00fff0);
  transform-origin: 50% 50%;
  animation: rotateDiamond 10s linear infinite;
}
@keyframes rotateDiamond {
  0% { transform: rotate(0deg);}
  100% { transform: rotate(360deg);}
}
</style>
<script>
// Animate the gradient direction for a shifting effect
(function animateGradient() {
  const grad = document.querySelector('#diamond-anim linearGradient');
  let t = 0, dir = 1;
  function animate() {
    t += dir * 0.005;
    if (t > 0.5 || t < 0) dir *= -1;
    grad.setAttribute('x1', 0 + t);
    grad.setAttribute('y1', 0 + t);
    grad.setAttribute('x2', 1 - t);
    grad.setAttribute('y2', 1 - t);
    requestAnimationFrame(animate);
  }
  animate();
})();
</script>
<?php include '../includes/footer.php'; ?>
