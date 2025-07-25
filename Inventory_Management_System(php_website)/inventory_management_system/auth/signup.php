<?php
// Signup form (Admin only)
include '../includes/config.php';
include '../includes/header.php';

// Check if an Admin already exists
$adminExists = false;
$checkAdmin = $conn->query("SELECT COUNT(*) as cnt FROM Users WHERE role = 'Admin'");
if ($checkAdmin && $row = $checkAdmin->fetch_assoc()) {
    $adminExists = ($row['cnt'] > 0);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Prevent signup if admin already exists
    if ($adminExists) {
        $error = 'Sorry, only admin can create user.';
    } else {
        $username = trim($_POST['username']);
        $email = trim($_POST['email']);
        $full_name = trim($_POST['full_name']);
        $password = $_POST['password'];
        $confirm_password = $_POST['confirm_password'];
        $role = 'Admin'; // Force Admin role
        if (!str_ends_with(strtolower($email), '.com')) {
            $error = 'Email must end with .com';
        } elseif ($password !== $confirm_password) {
            $error = 'Passwords do not match.';
        } else {
            $hash = password_hash($password, PASSWORD_DEFAULT);
            $stmt = $conn->prepare('INSERT INTO Users (username, email, full_name, password, role) VALUES (?, ?, ?, ?, ?)');
            $stmt->bind_param('sssss', $username, $email, $full_name, $hash, $role);
            if ($stmt->execute()) {
                $success = 'Admin account created successfully! You can now login.';
            } else {
                $error = 'Signup failed: ' . $conn->error;
            }
            $stmt->close();
        }
    }
}
if (!isset($error)) $error = '';
if (!isset($success)) $success = '';
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
    <div class="login-title">🧬 Create Account</div>
    <?php if ($error): ?>
      <div class="neon-alert neon-alert-danger text-center mb-3 animate__animated animate__fadeInDown">
        <i class="bi bi-exclamation-triangle-fill me-2"></i> <?php echo htmlspecialchars($error); ?>
      </div>
    <?php endif; ?>
    <?php if ($success): ?>
      <div class="neon-alert neon-alert-success text-center mb-3 animate__animated animate__fadeInDown">
        <i class="bi bi-check-circle-fill me-2"></i> <?php echo htmlspecialchars($success); ?>
      </div>
    <?php endif; ?>
    <?php if (!$adminExists): ?>
    <form method="post" action="signup.php" autocomplete="off">
      <div class="mb-3">
        <label for="username" class="form-label">Username</label>
        <input type="text" class="form-control" id="username" name="username" required>
      </div>
      <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" class="form-control" id="email" name="email" required>
      </div>
      <div class="mb-3">
        <label for="full_name" class="form-label">Full Name</label>
        <input type="text" class="form-control" id="full_name" name="full_name" required>
      </div>
      <input type="hidden" name="role" value="Admin">
      <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <input type="password" class="form-control" id="password" name="password" required>
      </div>
      <div class="mb-3">
        <label for="confirm_password" class="form-label">Confirm Password</label>
        <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
      </div>
      <button type="submit" class="btn btn-neon w-100">Create Account</button>
    </form>
    <?php else: ?>
      <div class="neon-alert neon-alert-warning text-center mt-4 mb-3 animate__animated animate__fadeInDown">
        <i class="bi bi-exclamation-octagon-fill me-2"></i> Sorry, only admin can create user.
      </div>
    <?php endif; ?>
    <a href="login.php" class="signup-link">Already have an account? Login here</a>
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
.neon-alert-success { border-color: #00fff0; background: linear-gradient(90deg, #23243a 0%, #00fff0 100%); color: #23243a; }
.neon-alert-warning { border-color: #ffe066; background: linear-gradient(90deg, #23243a 0%, #ffe066 100%); color: #23243a; }
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
