<?php // Common footer ?>
<footer class="neon-footer text-center py-4 mt-5">
  <div class="container">
    <div class="mb-2">
      <a href="/php_projects/final_project1/inventory_management_system/index.php" class="btn btn-outline-neon btn-sm me-2">Home</a>
      <?php if (isset($_SESSION['role'])): ?>
        <?php if ($_SESSION['role'] === 'Admin'): ?>
          <a href="/php_projects/final_project1/inventory_management_system/admin/index.php" class="btn btn-outline-neon btn-sm me-2">Dashboard</a>
        <?php elseif ($_SESSION['role'] === 'Manager'): ?>
          <a href="/php_projects/final_project1/inventory_management_system/manager/index.php" class="btn btn-outline-neon btn-sm me-2">Dashboard</a>
        <?php elseif ($_SESSION['role'] === 'Staff'): ?>
          <a href="/php_projects/final_project1/inventory_management_system/staff/index.php" class="btn btn-outline-neon btn-sm me-2">Dashboard</a>
        <?php endif; ?>
      <?php endif; ?>
      <a href="/php_projects/final_project1/inventory_management_system/auth/login.php" class="btn btn-outline-neon btn-sm me-2">Login</a>
      <a href="/php_projects/final_project1/inventory_management_system/auth/signup.php" class="btn btn-outline-neon btn-sm">Sign Up</a>
    </div>
    <div>Inventory Management System &copy; <?php echo date('Y'); ?> | Designed by AK~~37</div>
  </div>
</footer>
</body>
</html>
