

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

## 📸 Screenshots

### 🔐 Login Screen

<img src="https://github.com/user-attachments/assets/94436b26-b8ab-4f46-80c8-a9cc5f91d42a" width="800"/>

---

### 📝 Signup Screen

<img src="https://github.com/user-attachments/assets/f0936660-fd27-423b-9744-057dd433a530" width="800"/>

---

## 🧑‍💼 Admin Dashboard

### 👥 User Management

<img src="https://github.com/user-attachments/assets/d017110f-e419-4b74-ad32-b0553c4d463d" width="800"/>

---

### 📦 Inventory Management

<img src="https://github.com/user-attachments/assets/e45b63b3-e0b1-4825-b492-2f876770070f" width="800"/>

---

### 🚚 Supplier Management

<img src="https://github.com/user-attachments/assets/542a58f0-c517-4872-88d8-fcd45f26ea69" width="800"/>

---

### 📜 View Audit Logs

<img src="https://github.com/user-attachments/assets/2adfc52f-5e8d-4e53-a835-e413701e4d5a" width="800"/>

---

### ⚙️ System Settings

<img src="https://github.com/user-attachments/assets/0f24687e-7e89-469b-a6f5-fb7088e8459b" width="800"/>

---

## 📊 Manager Dashboard

### 📦 View & Manage Inventory

<img src="https://github.com/user-attachments/assets/f26a19c9-89ee-47d2-871e-a7f946246c03" width="800"/>

---

### 📁 View Transaction History

<img src="https://github.com/user-attachments/assets/db701e74-e8e2-48a3-b2d2-29dbaf43bbd5" width="800"/>

---

### 📑 Generate Reports

<img src="https://github.com/user-attachments/assets/d82a363a-b323-4d3d-9d0c-b5b89dcca2cb" width="800"/>

---

### 🏭 View Supplier Information

<img src="https://github.com/user-attachments/assets/0e51d88f-be5f-4726-92c3-b64862ddd002" width="800"/>


---

## 🧑‍🔧 Staff Dashboard

### 📋 View Inventory

<img src="https://github.com/user-attachments/assets/1ea5a637-b3e2-4d8c-ab8f-50da65c2d0a0" width="800"/>

---

### 📝 Record Transactions

<img src="https://github.com/user-attachments/assets/59fae3f0-51e5-4091-b58d-b118cc5934ba" width="800"/>

---

### 📄 View Transaction History

<img src="https://github.com/user-attachments/assets/158be484-ec8e-4151-b205-1c2352e83528" width="800"/>

---

### 🆘 Request Support from Admin

<img src="https://github.com/user-attachments/assets/b22b4172-ac26-4df2-a77f-05878ac2e977" width="800"/>

---










































