# 📱 Smart Complaint Management System Scope

---

## 🎯 Objective

Develop a **Flutter-based complaint management system** for the **Computer Science (CS)** department, allowing students to submit complaints to their **Batch Advisors**, who may escalate them to the **Head of Department (HOD)**. Admins manage users, batches, and departments through manual input or **CSV import**. The system supports 8 CS batches (FA18–FA25).

---

## 👥 User Roles & Responsibilities

### 🛠️ Admin

* **One-time Signup** with validated email (`@`, `.com`), password + confirmation. Credentials sent via **SMTP email**.
* **Login** using email and password.
* **Dashboard Features**:

  * **Add Users**:

    * **HOD/Batch Advisor**: Assign role and batch, send credentials via email.
    * **Student**: Auto-generate `BCS-XX` ID, assign department & batch, send credentials.
    * **CSV Import**: Upload CSV (`student_name`, `department`, `phone_no`, `batch_no`, `student_email`). Preview, edit, delete, confirm, and email credentials.
  * **Manage Batches**: Add FA18–FA25, assign one advisor per batch.
  * **Assign HOD** to CS department.
  * **View Complaints**: Access full complaint history with student, advisor, HOD, and status data.

### 👨‍🎓 Student

* **Login** using ID (e.g., `BCS-01`) and email.
* **Dashboard Features**:

  * **Submit Complaint**:

    * Fields: Dropdown Title (Transport, Course, Fee, Faculty, Personal, Other), Description, optional media (Google Drive link).
    * Auto-filled batch and advisor.
    * Auto-escalate to HOD when **5+ similar complaints** received.
  * **Complaint History**: View status, handler, comments.

### 👨‍🏫 Batch Advisor

* **Login** via email and password.
* **Dashboard Features**:

  * View complaints from their assigned batch.
  * Filter: Status, date, student.
  * Actions: Resolve, comment, escalate.
  * Auto-escalation after **24h** of inaction; advisor loses update access.
  * Timeline view of complaint lifecycle.

### 👨‍💼 HOD

* **Login** via email and password.
* **Dashboard Features**:

  * View escalated/priority (5+ same-title) complaints.
  * Filter: Batch, advisor, student.
  * Actions: Comment, Resolve, Reject.
  * Timeline view and priority focus.

---

## ✅ Functional Requirements

1. **Authentication**:

   * Admin: One-time signup with email validation.
   * Role-based login for Admin, Student, Advisor, HOD.
   * Student: Login with ID (username) and email (password).

2. **Admin Panel**:

   * Manual and CSV user creation.
   * Batch & HOD management.
   * Complaint monitoring.

3. **Student Complaint Module**:

   * Complaint submission with media support.
   * Batch/advisor auto-assignment.
   * 5+ similar complaints → HOD.

4. **Advisor Dashboard**:

   * Complaint filters & actions.
   * Auto-escalation rule.

5. **HOD Dashboard**:

   * Escalated/priority complaint handling.
   * Full complaint lifecycle.

6. **Complaint Lifecycle**:

   * Statuses: Submitted → In Progress → Escalated → Resolved/Rejected.

7. **Notifications**:

   * Real-time updates via **Supabase Realtime**.
   * SMTP emails for user creation.

8. **CSV Handling**:

   * Editable import, previews, and email automation.

---

## 🧱 Tech Stack

* **Frontend**: Flutter (Role-based UI)
* **Backend**: Supabase (Auth, DB, Realtime)
* **IDE**: Android Studio
* **Email**: SMTP (Gmail)
* **Packages**: `csv`, `mailer`, `email_validator`, `url_launcher`
* **Media**: Google Drive (public links)

---

## 📧 Email Delivery

* **HTML Templates** with validation and feedback via snackbar/confirm dialogs.

### Admin Signup

* Sends credentials and role info.
* Email & dialog validation.

### HOD/Advisor Creation

* Sends credentials, batch/role details.

### Student Creation

* Manual or CSV, generates `BCS-XX` IDs.
* Sends credentials and batch info.

### Email System

* Uses Gmail SMTP (`smtp.gmail.com`, port 587).
* HTML features: Greeting, credentials, CS branding, unsubscribe link.

---

## 🗃️ Supabase Database Schema

Includes:

* `departments`, `batches`, `profiles`, `complaints`, `complaint_timeline`
* Triggers:

  * `update_complaints_timestamp`
  * `handle_same_title_complaints`
  * `auto_escalate_complaints`
  * `validate_batch_advisor`
  * `assign_batch_advisor`
* Indexing for performance.
* Full SQL block included in supabase directory.

---

## 🔐 Row-Level Security (RLS)

* Enabled on all relevant tables.
* Fine-grained access per role:

  * Students can read/write only their complaints.
  * Advisors/HODs can access only their assigned complaints.
  * Admins have full access.
* Additional rules for:

  * Timeline entries
  * Department-wide visibility (HOD)
  * Advisor access to assigned students

---

## 🛠️ Implementation Notes

* **Packages**: `supabase_flutter`, `mailer`, `csv`, etc.
* **SMTP**: Gmail setup using app password.
* **Automation**: Scheduled auto-escalation via Edge Functions/cron.
* **Testing**: Android Studio emulator.
* **Security**: Email validation, RLS, Google Drive media checks.

---

This documentation defines the **complete blueprint** for developing and deploying a scalable and secure Smart Complaint Management System tailored for the CS department.

## 🛠️ Smart Complaint System  
### 📱 App Screenshots

A simple and efficient mobile solution for managing user complaints with role-based access.

---

### 🏠 Home & Navigation

| Loading Screen | Home Screen | Menu Bar |
|----------------|-------------|-----------|
| <img src="https://github.com/user-attachments/assets/fc156e6e-cc26-43f3-990d-934eff6baf15" width="200"/> | <img src="https://github.com/user-attachments/assets/556a9021-0e0b-48f9-b86f-abc3557435d0" width="200"/> | <img src="https://github.com/user-attachments/assets/476a639b-3501-4656-8e80-124d70a29a33" width="200"/> |

---

### 🔐 Account Access

| Login Screen | Signup Screen | Denied Signup |
|--------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/5028d6e5-6ef3-4b1f-9b8a-0c61caa66672" width="200"/> | <img src="https://github.com/user-attachments/assets/e97daf29-6d2c-43ba-bd97-83a3ef4fc1dc" width="200"/> | <img src="https://github.com/user-attachments/assets/e5a505cd-7396-4cc8-a5a8-bea67a059c62" width="200"/> |

---

## 🛠️ Admin Dashboard  
### 📊 Interface Screenshots

Efficient admin panel to manage departments, students, batches, and complaints.

---

### 📌 Main Dashboard Views

| Dashboard | System Overview | Quick Actions | Menu Bar | Profile |
|-----------|------------------|----------------|----------|---------|
| <img src="https://github.com/user-attachments/assets/04aa6d63-6356-4def-886e-88ba13571cb9" width="150"/> | <img src="https://github.com/user-attachments/assets/10f067c7-d99b-471e-96cd-ab4be38854de" width="150"/> | <img src="https://github.com/user-attachments/assets/24be5b3d-3abe-4beb-b94e-18e0262fce3f" width="150"/> | <img src="https://github.com/user-attachments/assets/4e9ab510-49ca-4caf-bb20-f8f5881e3ce9" width="150"/> | <img src="https://github.com/user-attachments/assets/34dcf328-f230-4cfc-b178-41ad86f076ab" width="150"/> |

---

### 🧑‍💼 Admin Management Modules

| Departments | Batches | HODs | Advisors | Students |
|-------------|---------|------|----------|----------|
| <img src="https://github.com/user-attachments/assets/b1cf6912-3ba7-4bc1-899a-28cc1a4a02ad" width="150"/> | <img src="https://github.com/user-attachments/assets/66556aad-f964-447a-9cbd-06a8c01376cd" width="150"/> | <img src="https://github.com/user-attachments/assets/b4d0cf1b-11aa-4f6d-bfd0-a02bbea53268" width="150"/> | <img src="https://github.com/user-attachments/assets/c1e69b21-bc49-4960-91d9-11f75da17a2f" width="150"/> | <img src="https://github.com/user-attachments/assets/4bbc05af-9b71-40ee-9a7a-ff8e56764e01" width="150"/> |

---

### 🗂️ Batch & Complaint Overview

| Batches Overview | Batches Detail | Complaints Detail |
|------------------|----------------|---------------------|
| <img src="https://github.com/user-attachments/assets/9ae7f485-2992-4b22-836b-329f73c57b54" width="150"/> | <img src="https://github.com/user-attachments/assets/9bd464e9-c6d6-46be-bf2c-9c87948ec043" width="150"/> | <img src="https://github.com/user-attachments/assets/2ceee480-e6c8-40f6-acbb-273ceaa959b3" width="150"/> |

---

## 🎓 Student Dashboard  
### 📱 App Interface Screenshots

Overview of student-facing features such as complaints, profiles, and quick access tools.

---

### 🔍 Main Screens

| Dashboard | Quick Actions | Menu Bar | Profile |
|-----------|----------------|----------|---------|
| <img src="https://github.com/user-attachments/assets/e2e1a6db-8521-43b6-b16a-d402cad6d8e9" width="150"/> | <img src="https://github.com/user-attachments/assets/aa4e00a9-4b67-4c46-aefb-cc88c30eb5d6" width="150"/> | <img src="https://github.com/user-attachments/assets/600504f6-8596-40f9-906a-5f0d17325b8b" width="150"/> | <img src="https://github.com/user-attachments/assets/0306fccd-4f7d-47dd-9a35-3e50876f8fd3" width="150"/> |

---

### 📝 Complaints & Support

| Sent Complaints | Complaint Status | Support & Help | — |
|------------------|------------------|----------------|----|
| <img src="https://github.com/user-attachments/assets/2518fc49-40ee-4715-af40-fb49524932b7" width="150"/> | <img src="https://github.com/user-attachments/assets/0dfd6006-2c80-4aad-90f3-6f9a80009ab5" width="150"/> | <img src="https://github.com/user-attachments/assets/b3860bc6-403f-4486-bfea-194b7034eb64" width="150"/> |  |

---

## 🧑‍🏫 Batch Advisor Dashboard  
### 📲 Application Interface Screens

Overview of core functionalities available to batch advisors.

---

### 🧭 Main Navigation

| Dashboard | Quick Actions | Menu Bar | Profile | View Students |
|-----------|----------------|----------|---------|----------------|
| <img src="https://github.com/user-attachments/assets/ba0be898-3efc-49ec-897c-b2574dead443" width="150"/> | <img src="https://github.com/user-attachments/assets/d9652ffd-abde-4c69-b928-0c45846d4dbe" width="150"/> | <img src="https://github.com/user-attachments/assets/258e5261-5986-4803-be11-70b4589cf0dc" width="150"/> | <img src="https://github.com/user-attachments/assets/76a8f814-2ae3-4443-84f4-587a462eade0" width="150"/> | <img src="https://github.com/user-attachments/assets/d59ee2c3-a75e-4184-bc66-3e827957a82a" width="150"/> |

---

### 📋 Complaints & Reports

| View Complaints | Update Status | Reports | Help & Support | — |
|------------------|----------------|---------|----------------|----|
| <img src="https://github.com/user-attachments/assets/2bef9ee2-b3f9-4589-8d2f-f7f2013c6cfe" width="150"/> | <img src="https://github.com/user-attachments/assets/6e59606c-d4f9-4cd9-a9b6-d2f2d6b68385" width="150"/> | <img src="https://github.com/user-attachments/assets/cbe4a00e-42f1-4907-9d18-355e43a458d6" width="150"/> | <img src="https://github.com/user-attachments/assets/ab3da52d-d5f0-4746-815f-b090c3d619e0" width="150"/> |  |

---

## 🧑‍💼 HOD Dashboard  
### 📲 Application Interface Screens

Functional screens available for Head of Department operations.

---

### 🧭 Main Controls

| Dashboard | Quick Actions | Menu Bar | Profile | View Batch Advisors |
|-----------|----------------|----------|---------|----------------------|
| <img src="https://github.com/user-attachments/assets/f22e16db-2fe0-40bd-928d-702cbb8f1afc" width="150"/> | <img src="https://github.com/user-attachments/assets/836da22c-23d3-4832-89aa-b2407da43ed3" width="150"/> | <img src="https://github.com/user-attachments/assets/320e270a-97f7-449e-b33a-2484c754adb1" width="150"/> | <img src="https://github.com/user-attachments/assets/05003790-f6eb-491c-9a6f-c55ab69a5fbc" width="150"/> | <img src="https://github.com/user-attachments/assets/3d657f69-f34d-418c-9a77-a198e19f14f1" width="150"/> |

---

### 📋 Complaint & System Management

| Esclated Complaints | Update Status | Reports | Help & Support | Settings |
|---------------------|----------------|---------|----------------|----------|
| <img src="https://github.com/user-attachments/assets/62bcfaa0-f9bd-480d-b66b-d95e75ea4408" width="150"/> | <img src="https://github.com/user-attachments/assets/c55b6855-2a04-4dd5-9877-54534f345809" width="150"/> | <img src="https://github.com/user-attachments/assets/eadb6e13-998c-42d2-a654-b6c1cee74966" width="150"/> | <img src="https://github.com/user-attachments/assets/178ba80a-c86d-41b6-bae5-652484d96965" width="150"/> | <img src="https://github.com/user-attachments/assets/c42e46a7-503d-4dad-8b50-326551e9f571" width="150"/> |




---

### 📊 Dashboard

<p float="left">
  <img src="https://github.com/user-attachments/assets/a58d5b3a-16df-44ac-ae71-b880006e564d" width="45%" />
  <img src="https://github.com/user-attachments/assets/f1acdb5f-d153-46c5-8c77-23e21b0538ae" width="45%" />
</p>

---

### 📈 Smart Analysis

<p float="left">
  <img src="https://github.com/user-attachments/assets/1b2c7c41-317b-4318-932b-5f53d0d24749" width="24%" />
  <img src="https://github.com/user-attachments/assets/3f1e3e6a-0a63-4089-b23c-53b6669c8eaa" width="24%" />
  <img src="https://github.com/user-attachments/assets/a95d1ddb-456c-4f18-8308-e97ff2a8963d" width="24%" />
  <img src="https://github.com/user-attachments/assets/a27f38a3-48b9-495e-b9f0-ec7ef214836e" width="24%" />
</p>

---

### 💰 Budget Goals

<p float="left">
  <img src="https://github.com/user-attachments/assets/a4773238-5a38-4467-9b7b-f1b3a90f3835" width="24%" />
  <img src="https://github.com/user-attachments/assets/d720c015-6bb8-4370-aaf2-f27cc3c9abe0" width="24%" />
  <img src="https://github.com/user-attachments/assets/262f8466-0157-48e5-8445-c5c5a8c7a831" width="24%" />
  <img src="https://github.com/user-attachments/assets/96ef8c53-64da-4a38-9eb6-978463e8ed83" width="24%" />
</p>

---



### 🤖 Chat Bot

<p float="left">
  <img src="https://github.com/user-attachments/assets/41301f93-a652-46a5-badd-3df5cbc6876c" width="45%" />
</p>

---































































































