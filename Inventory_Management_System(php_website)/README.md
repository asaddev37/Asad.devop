<img width="539" height="237" alt="image" src="https://github.com/user-attachments/assets/d59bcbfc-be67-481e-90da-dcd8700698f0" /># Inventory Management System Scope Overview (PHP, HTML, CSS, JS, MySQL)

## ✨ Project Summary

A modern, web-based **Inventory Management System** rebuilt from a legacy C# WPF application. Built with **vanilla PHP**, **MySQL**, and enhanced using **HTML**, **CSS (Bootstrap 5)**, and **JavaScript (jQuery + DataTables)**. The system is secure, scalable, and features role-based portals for **Admin**, **Manager**, and **Staff** with authentication, reports, audit logs, and inventory operations.

---

## 🌐 Tech Stack

* **Frontend**: HTML5, CSS3 (Bootstrap 5), JS (jQuery, DataTables.js)
* **Backend**: PHP (vanilla, no framework)
* **Database**: MySQL (same schema as original WPF)
* **Tools & Libraries**:

  * Dompdf (PDF export)
  * Composer (dependency management)
  * XAMPP/WAMP (local server)

---

## 🔹 Features by Role

### 👨‍💼 Admin Portal

* Full control: user, inventory, supplier & logs management
* Exportable audit logs (CSV/PDF)
* System config & DB backup/restore

### 👩‍💼 Manager Portal

* Inventory oversight
* Transaction history + export
* Reporting tools

### 👩‍👷 Staff Portal

* Daily inventory operations
* Transaction logs (personal)
* Flag low-stock items

---

## 📄 Database Schema (Core Tables)

* **Users**: id, username, password, role, email, full\_name, timestamps
* **Inventory**: id, name, category, quantity, unit\_price, supplier\_id
* **Transactions**: id, item\_id, user\_id, type (Add/Remove/Update), date
* **Suppliers**: id, name, contact\_info
* **AuditLogs**: user\_id, action, timestamp, details

---

## 🏠 Project Structure

```bash
inventory-management-system/
├── admin/         # Admin Portal
├── manager/       # Manager Portal
├── staff/         # Staff Portal
├── auth/          # Login/Signup/Logout
├── includes/      # Common PHP config/functions
├── assets/        # CSS/JS
├── vendor/        # Composer dependencies
├── database/      # SQL setup
```

---

## 🔐 Authentication System

* Role-based sessions with secure login/signup
* Passwords hashed via `password_hash()`
* Session timeout & access control
* Activity logging via `logActivity()`

---

## ✨ Highlights

* Clean, modular code for easy maintenance
* Secure with input validation, CSRF protection & SQLi prevention
* Responsive UI with Bootstrap + DataTables.js
* PDF exports via Dompdf

---

## ✅ Deliverables

* Source code (PHP + MySQL)
* Setup scripts (`setup.sql`)
* User manuals (Admin, Manager, Staff)
* README documentation (this file!)

---

## ⚡ Future Upgrades

* Email alerts (via PHPMailer)
* Barcode scanner support (QuaggaJS)
* Charts & graphs (Chart.js)
* Multi-language interface

---

## ✍ Setup Steps

1. Clone repo and configure DB in `includes/config.php`
2. Run `setup.sql` to initialize schema
3. Install Dompdf via Composer
4. Launch via XAMPP/WAMP and login as Admin

---

## 🚀 Live Preview

```
http://localhost/inventory-management-system/
```

Admin login: `admin / admin123`

> *Built with care using pure PHP and clean UI components.*

## 🖼️ Web Screenshots

<img src="https://github.com/user-attachments/assets/bbea40d6-ef09-48c2-9555-076bfce9e631" width="800"/>

<img src="https://github.com/user-attachments/assets/af86447a-abe8-4fa3-829b-20b0a77ee5ed" width="800"/>

<img src="https://github.com/user-attachments/assets/750f5ff7-7e42-4061-b0f3-cba6d12e7d20" width="800"/>

<img src="https://github.com/user-attachments/assets/011b73f9-5f0b-47f8-98f2-2af73eb9f7a4" width="800"/>














