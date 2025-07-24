

---

# 📦 Inventory Management System

A powerful desktop application built using **C#**, **WPF**, and **MySQL**, designed to streamline inventory tracking, user management, and operational oversight through a clean interface and robust role-based access.

---

## 🔍 Project Overview

The **Inventory Management System** enables efficient inventory control across three user roles:

* 👨‍💼 **Admin**: Full system access and user management.
* 📊 **Manager**: Inventory oversight, reporting, and transaction tracking.
* 🧑‍🔧 **Staff**: Day-to-day stock handling and updates.

Built with **WPF** for a responsive UI, **MySQL** for data handling, and **C#** for business logic, the system ensures security, scalability, and ease of use.

---

## 🎯 Key Objectives

* ✅ Intuitive and responsive UI.
* 🔐 Secure login & signup with password hashing.
* 🔄 Role-based functionality for Admins, Managers, and Staff.
* 💾 Centralized MySQL database.
* 📈 Scalable for future feature expansion.

---

## 🧰 Tech Stack

| Component       | Technology                                       |
| --------------- | ------------------------------------------------ |
| 🖥 Frontend     | WPF (Windows Presentation Foundation)            |
| ⚙ Backend       | C# with Visual Studio                            |
| 🗄 Database     | MySQL                                            |
| 🔌 Connectivity | MySQL Connector/NET, Entity Framework (optional) |
| 🔐 Security     | BCrypt (or similar) for password hashing         |

---

## 🧩 System Modules

### 🗃️ Database Schema Highlights

* **Users**: Stores credentials, roles, and activity logs.
* **Inventory**: Tracks items, stock levels, pricing.
* **Suppliers**: Supplier details and contacts.
* **Transactions**: Stock movement logs.
* **AuditLogs**: System action logs for transparency.

---

### 🔐 Authentication

* **Login**:

  * Secure login with hashed password validation.
  * Role-based redirection (Admin, Manager, Staff).
  * Logs login attempts and actions in `AuditLogs`.

* **Signup**:

  * Admins can register Managers and Staff.
  * Enforces unique usernames, email validation, and password strength.

---

## 🧭 User Portals

### 👨‍💼 Admin Portal

Full control over users, inventory, suppliers, and logs.

**Features**:

* Create/edit/delete users.
* Inventory CRUD operations.
* Supplier management.
* View/filter audit logs.
* Configure system settings (e.g., thresholds, session timeouts).
* Database backup/restore.

---

### 📊 Manager Portal

Oversees inventory health, stock movement, and reporting.

**Features**:

* Modify stock levels.
* View & filter transaction logs.
* Generate & export reports (CSV/PDF).
* Read-only supplier access.

---

### 🧑‍🔧 Staff Portal

Handles daily inventory operations.

**Features**:

* Adjust stock quantities.
* Flag low-stock items.
* View personal transaction history.
* Read-only access to item pricing.

---

## 🏗️ Implementation Guidelines

### 🗂️ Project Structure (Visual Studio)

* `Views/` – UI components (XAML)
* `ViewModels/` – Logic and data binding
* `Models/` – Entity classes
* `Services/` – Business logic (e.g., DB services)
* `Utils/` – Helpers (e.g., hashing, converters)
* `Resources/` – Images, themes
* `Database/` – SQL scripts for schema and seed data

```bash
InventoryManagementSystem/
├── Views/
├── ViewModels/
├── Models/
├── Services/
├── Utils/
├── Resources/
├── Database/
```

---

### 🛡️ Security Best Practices

* Hash passwords with **BCrypt**.
* Input validation to prevent SQL injection.
* Sensitive actions logged in `AuditLogs`.
* Enforce session timeouts.

---

### 🧪 Testing Strategy

* ✅ **Unit Tests** – Validate business logic and DB functions.
* 🔄 **Integration Tests** – End-to-end workflows.
* 🧪 **UI Tests** – Verify navigation, styling, and usability.

---

## 📦 Deliverables

* Complete Visual Studio solution.
* MySQL database with schema and seed data.
* Detailed scope documentation (this file).
* End-user manual for all roles.

---


