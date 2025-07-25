-- Inventory Management System Database Setup
-- Database: inventory_system

CREATE DATABASE IF NOT EXISTS inventory_system;
USE inventory_system;

-- Users Table
CREATE TABLE IF NOT EXISTS Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Manager', 'Staff') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME NULL
);

-- Suppliers Table
CREATE TABLE IF NOT EXISTS Suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100),
    address TEXT
);

-- Inventory Table
CREATE TABLE IF NOT EXISTS Inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INT NOT NULL DEFAULT 0,
    unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    supplier_id INT,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(id) ON DELETE SET NULL
);

-- Transactions Table
CREATE TABLE IF NOT EXISTS Transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    user_id INT NOT NULL,
    type ENUM('Add', 'Remove', 'Update') NOT NULL,
    quantity INT NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    FOREIGN KEY (item_id) REFERENCES Inventory(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- AuditLogs Table
CREATE TABLE IF NOT EXISTS AuditLogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Settings Table
CREATE TABLE IF NOT EXISTS settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    param_key VARCHAR(50) NOT NULL UNIQUE,
    param_value VARCHAR(255) NOT NULL
);

-- Optional: PendingRequests Table (for Manager requests)
CREATE TABLE IF NOT EXISTS PendingRequests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INT NOT NULL,
    requested_by INT NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    request_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requested_by) REFERENCES Users(id) ON DELETE CASCADE
);

-- Seed initial Admin, Manager, and Staff users (default passwords: admin123, manager123, staff123)
INSERT INTO Users (username, password, role, email, full_name, created_at)
VALUES 
('admin', '$2y$10$wH8Qw8Qw8Qw8Qw8Qw8Qw8O8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw', 'Admin', 'admin@example.com', 'System Administrator', NOW()),
('manager', '$2y$10$wH8Qw8Qw8Qw8Qw8Qw8Qw8O8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw', 'Manager', 'manager@example.com', 'Default Manager', NOW()),
('staff', '$2y$10$wH8Qw8Qw8Qw8Qw8Qw8Qw8O8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw8Qw', 'Staff', 'staff@example.com', 'Default Staff', NOW())
ON DUPLICATE KEY UPDATE username=username;

INSERT INTO AuditLogs (user_id, action, details, timestamp)
VALUES
  (1, 'Login', 'Admin logged in', NOW()),
  (2, 'Add Inventory', 'Manager added new item', NOW()),
  (3, 'Edit Supplier', 'Staff edited supplier info', NOW()),
  (1, 'Delete User', 'Admin deleted user', NOW()),
  (2, 'Update Settings', 'Manager updated system settings', NOW());


  -- Requests table for staff-to-manager requests
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    manager_id INT NOT NULL,
    type VARCHAR(100) NOT NULL,
    details TEXT NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (manager_id) REFERENCES Users(id) ON DELETE CASCADE
);
