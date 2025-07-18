### 📱 Smart Complaint Management System Scope

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

| Loading Screen                                                                                           | Home Screen                                                                                              | Menu Bar                                                                                                 |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/628d44fe-6955-4aa8-a6de-1a7bf9b70bdb" width="200"/> | <img src="https://github.com/user-attachments/assets/263e8dfd-f9fa-4fdd-8e07-1c383af7a136" width="200"/> | <img src="https://github.com/user-attachments/assets/5ce642c5-f116-4b9a-9d09-fb7ada427cff" width="200"/> |


| About Screen                                                                                             | Policy Screen                                                                                            | Contact Screen                                                                                           |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/91c7cec5-243b-4dca-b36d-648ae6ba3248" width="200"/> | <img src="https://github.com/user-attachments/assets/a8e2e9fa-89e0-4729-bc29-a9cdabcb60cf" width="200"/> | <img src="https://github.com/user-attachments/assets/174049d9-0bfe-4bc5-b33a-a00d44785174" width="200"/> |


### 🔐 Account Access

| Login Screen                                                                                             | Signup Screen                                                                                            | Denied Signup                                                                                            |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/695d216b-8ac5-46aa-b1bc-a104785e8be0" width="200"/> | <img src="https://github.com/user-attachments/assets/4bb1e92e-2352-4883-9926-b27f37bb5b78" width="200"/> | <img src="https://github.com/user-attachments/assets/c3ba17f5-0a34-4f19-bf13-0057abfb3b47" width="200"/> |


## 🛠️ Admin Dashboard  
### 📊 Interface Screenshots

Efficient admin panel to manage departments, students, batches, and complaints.

---

### 📌 Main Dashboard Views

| Dashboard                                                                                                | System Overview                                                                                          | Quick Actions                                                                                            | Menu Bar                                                                                                 | Profile                                                                                                  |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/b3cdf6c3-48da-4f6f-ab1a-f831f389d3fb" width="150"/> | <img src="https://github.com/user-attachments/assets/284a8598-1cb8-4f35-a29e-a7422a0bc85e" width="150"/> | <img src="https://github.com/user-attachments/assets/d5e7b3ec-78db-497f-b70a-25c0b39bd7a2" width="150"/> | <img src="https://github.com/user-attachments/assets/28dfeaf0-54af-42b7-82bd-a417043993db" width="150"/> | <img src="https://github.com/user-attachments/assets/da9213d2-373f-432e-a51b-afa777acc7e6" width="150"/> |


### 🧑‍💼 Admin Management Modules

| Departments                                                                                              | Batches                                                                                                  | HODs                                                                                                     | Advisors                                                                                                 | Students                                                                                                 |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/a1937158-7e47-4918-aca9-7daee22224ec" width="150"/> | <img src="https://github.com/user-attachments/assets/d5c601fc-cde3-4f5d-9201-dd774846c21e" width="150"/> | <img src="https://github.com/user-attachments/assets/794d5a71-521a-4832-807b-ce61bdee998d" width="150"/> | <img src="https://github.com/user-attachments/assets/b8545942-4002-42d8-8afc-7c4812ea683d" width="150"/> | <img src="https://github.com/user-attachments/assets/a97c8d19-8d3f-4fc7-b648-c9b2a1dff2e3" width="150"/> |


### 🗂️ Batch & Complaint Overview

| Batches Overview                                                                                         | Batches Detail                                                                                           | Complaints Detail                                                                                        |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/38975537-4986-405f-98f1-19183708db5f" width="150"/> | <img src="https://github.com/user-attachments/assets/e9b4f4fa-012a-43f3-9721-27d718eb85bb" width="150"/> | <img src="https://github.com/user-attachments/assets/461f129e-4c5f-46df-8954-50fe7e61f379" width="150"/> |


## 🎓 Student Dashboard  
### 📱 App Interface Screenshots

Overview of student-facing features such as complaints, profiles, and quick access tools.

---

### 🔍 Main Screens

| Dashboard                                                                                                | Quick Actions                                                                                            | Menu Bar                                                                                                 | Profile                                                                                                  |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/fd1e41e6-cb1e-4e18-8703-7e55f673cc4d" width="150"/> | <img src="https://github.com/user-attachments/assets/fe8922f8-6ec1-45dd-9277-13a0241f414e" width="150"/> | <img src="https://github.com/user-attachments/assets/ad94254c-d6f7-49d2-8ab5-583262092319" width="150"/> | <img src="https://github.com/user-attachments/assets/5fdfb108-4323-4d49-875d-e4fff7f2aa8a" width="150"/> |



### 📝 Complaints & Support

| Sent Complaints                                                                                          | Complaint Status                                                                                         | Support & Help                                                                                           | — |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | - |
| <img src="https://github.com/user-attachments/assets/5d7015e9-87cf-4272-89d3-32cb5b5e95d2" width="150"/> | <img src="https://github.com/user-attachments/assets/06bba2ba-8065-4902-97fe-eeb31540a60b" width="150"/> | <img src="https://github.com/user-attachments/assets/37b64dec-70fb-41d5-bb1a-7cb3aa32441d" width="150"/> |   |



## 🧑‍🏫 Batch Advisor Dashboard  
### 📲 Application Interface Screens

Overview of core functionalities available to batch advisors.

---

### 🧭 Main Navigation

| Dashboard                                                                                                | Quick Actions                                                                                            | Menu Bar                                                                                                 | Profile                                                                                                  | View Students                                                                                            |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/0e9ee355-cf0b-4e45-ae59-e41532bd303b" width="150"/> | <img src="https://github.com/user-attachments/assets/d36cc016-6473-4f6b-826f-6db6168720fa" width="150"/> | <img src="https://github.com/user-attachments/assets/7845eb5e-f6ad-414f-9df7-dd0a1ad08404" width="150"/> | <img src="https://github.com/user-attachments/assets/21ed14ef-ce59-40c3-939d-6138ccdb0433" width="150"/> | <img src="https://github.com/user-attachments/assets/372b710a-946e-4fe5-878f-2ea07205a27f" width="150"/> |



### 📋 Complaints & Reports

| View Complaints                                                                                          | Update Status                                                                                            | Reports                                                                                                  | Help & Support                                                                                           | — |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | - |
| <img src="https://github.com/user-attachments/assets/3ff50f37-1232-4724-b119-48ab90592f93" width="150"/> | <img src="https://github.com/user-attachments/assets/4773f839-d819-49b2-a352-b116a766693a" width="150"/> | <img src="https://github.com/user-attachments/assets/e784b971-91af-4870-a03f-cd8ffa32bbf4" width="150"/> | <img src="https://github.com/user-attachments/assets/bdcb030e-adb0-4b49-880a-9ec6a3875b70" width="150"/> |   |


## 🧑‍💼 HOD Dashboard  
### 📲 Application Interface Screens

Functional screens available for Head of Department operations.

---

### 🧭 Main Controls

| Dashboard                                                                                                | Quick Actions                                                                                            | Menu Bar                                                                                                 | Profile                                                                                                  | View Batch Advisors                                                                                      |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/08a60ed5-fb7f-45c4-b979-12795854423d" width="150"/> | <img src="https://github.com/user-attachments/assets/825ce56b-0df8-4f99-8f36-d86ad51b0784" width="150"/> | <img src="https://github.com/user-attachments/assets/b4c26384-e4f2-4a90-a792-49abaa8f4185" width="150"/> | <img src="https://github.com/user-attachments/assets/895b3cdf-27e2-454e-8bdb-9d724d43342f" width="150"/> | <img src="https://github.com/user-attachments/assets/12e7df19-2027-4a4b-b2c7-fd4e8fa01cba" width="150"/> |


### 📋 Complaint & System Management

| Esclated Complaints                                                                                      | Update Status                                                                                            | Reports                                                                                                  | Help & Support                                                                                           | Settings                                                                                                 |
| -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/user-attachments/assets/7a9ece31-32f4-47f7-9a28-fee7cf05751c" width="150"/> | <img src="https://github.com/user-attachments/assets/0dd17284-6c6e-426b-9c66-872dd157cf78" width="150"/> | <img src="https://github.com/user-attachments/assets/7d6bbfc7-4a32-4de3-8b6c-8377016f2f75" width="150"/> | <img src="https://github.com/user-attachments/assets/d958706d-0c4f-40aa-9d57-1e9af6f41bce" width="150"/> | <img src="https://github.com/user-attachments/assets/5d54f005-26fd-460b-b78b-1c46e2308efa" width="150"/> |


---

## 📧 Email Login Credentials

### Screenshots:

| Admin Email                                                                                     | Student Email                                                                                     | Batch Advisor Email                                                                                     | HOD Email                                                                                     |
| ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| ![Admin Email](https://github.com/user-attachments/assets/5f0bd0e9-8589-4a29-8b27-79238d1bd388) | ![Student Email](https://github.com/user-attachments/assets/26db1488-be1a-4a48-ae9b-981b2f943843) | ![Batch Advisor Email](https://github.com/user-attachments/assets/2ee3cadd-dcf6-4b62-be39-2294eb0f2738) | ![HOD Email](https://github.com/user-attachments/assets/35ab9417-c125-460b-a244-dbeaa323a31e) |



---


## 🎥 Supported Demo Video

You can watch a demo of the system in action via the link below:

🔗 [Click here to view the video](https://drive.google.com/file/d/10dmUWM8dqSloW1vUBRlrKuNzs0nW95Rl/view?usp=sharing)

> 📁 *Hosted on Google Drive – ensure you're logged into your Google account to view.*


---


## 📦 Download APK File

You can download the latest version of the APK from the link below:

🔗 [Download APK](https://drive.google.com/file/d/1BOcJWt5Ofu2pcsiYrmFmGIrsLc3QmuN9/view?usp=sharing)

> 📁 *Hosted on Google Drive – make sure you're signed in to access the file.*



---
































































































