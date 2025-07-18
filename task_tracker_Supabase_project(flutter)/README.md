

✅ **Supabase** as the cloud database
✅ **Flutter** for frontend (Admin & Student)
✅ No backend server (using Supabase directly)
✅ Functional requirements, tools, and dependencies

---

# 📄 **Scope Document – Student Task Tracker App (Real-time with Supabase)**

---

## ✅ **Project Title**

**Student Task Tracker App**
(*Real-time with Supabase & Flutter*)

---

## 🎯 **Core Use Case**

* **Admin (Teacher)** creates students, assigns tasks, and monitors their progress.
* **Students** view and complete their tasks, and track performance using real-time graphs.

---

## 👥 **Roles**

### 🧑‍🏫 **Admin (Teacher)**

* Add students (manually or from Excel)
* Assign tasks to specific students
* Track student performance via reports/graphs
* Delete students and their tasks
* View top performers
* Additional: Chat with students

### 🎓 **Student**

* Login with credentials provided by Admin
* View assigned tasks
* Mark tasks as completed
* View personal progress graph
* Additional: See task streaks or leaderboard

---

## 📱 **App Structure**

* **2 Flutter Apps (or roles within same app)**

  * `Admin App`
  * `Student App`

---

## 🔐 **Authentication**

* Use **Supabase Auth**:

  * password login
  * Admin creates credentials for students
  * Supabase manages secure auth tokens

---

## 🗃️ **Cloud Database: Supabase**

* PostgreSQL (via Supabase)
* Real-time subscriptions (enabled for `tasks`, `reports`, `messages`)
* Hosted in **Mumbai region (ap-south-1)** for Pakistan

### ✳️ **Tables in Supabase**

| Table Name    | Purpose                                           |
| ------------- | ------------------------------------------------- |
| `users`       | Admins & Students (with role field)               |
| `tasks`       | Task data with assignment and completion          |
| `reports`     | (additional) Track progress/performance             |
| `messages`    | (additional) Real-time chat between admin & student |
| `leaderboard` | (additional) Track top student performance          |

---

## 🧠 **Functional Requirements**

### Admin App:

* [ ] Add students (form or Excel upload)
* [ ] Assign tasks
* [ ] View student task reports
* [ ] Export data
* [ ] View performance graphs
* [ ] View top performers
* [ ] Chat with students (Additional)

### Student App:

* [ ] Login
* [ ] View assigned tasks
* [ ] Mark tasks as completed
* [ ] View progress graph
* [ ] See leaderboard (additional)
* [ ] Chat with teacher (additional)

---

## 📦 **Technology Stack**

| Component     | Tool                                           |
| ------------- | ---------------------------------------------- |
| Frontend      | Flutter (Android Studio)                       |
| Database      | Supabase (PostgreSQL + Real-Time + Auth)       |
| Charts        | `fl_chart`                                     |
| File Upload   | `file_picker`, `excel` (Admin only)            |
| State Mgmt    | `Provider` or `Riverpod`                       |
| Real-time     | `supabase_flutter` stream API                  |
| PDF/Export    | `pdf`, `printing`, `csv` (for admin reports)   |


---

---

## 📈 Additional Features (Phase 2)

* ✅ Push notifications (via Supabase Edge Functions + OneSignal)
* ✅ In-app messaging
* ✅ Weekly/monthly reports
* ✅ Email auto-sending credentials to students
* ✅ Dark/light theme toggle

---

# 🧠 Task_admin App  
### 📱 App Screenshots

Efficiently manage students, tasks, and performance insights — all in one place!

---

### 🔐 Authentication & Dashboard (Admin)

| Loading Screen | Admin Login | Admin Dashboard | Chat List | Student Chat |
|----------------|-------------|------------------|-----------|---------------|
| <img src="https://github.com/user-attachments/assets/62fb9a72-16f2-4900-8daa-7efcaa21e0dd" width="200"/> | <img src="https://github.com/user-attachments/assets/929815e7-1654-4c53-9f96-c37e50af4c08" width="200"/> | <img src="https://github.com/user-attachments/assets/059ffca5-88c0-4ca1-8190-b78eaa17db0a" width="200"/> | <img src="https://github.com/user-attachments/assets/6e95acae-09c9-464a-9f87-6070fc41b4a6" width="200"/> | <img src="https://github.com/user-attachments/assets/233c983b-dc1d-4c29-962b-2be889643daf" width="200"/> |

---

### 👥 User & Task Management (Admin)

| Student Management | Task Management | Assign Task | View All Tasks | Settings Screen |
|---------------------|------------------|-------------|----------------|------------------|
| <img src="https://github.com/user-attachments/assets/898007eb-8f99-4173-98c2-f12aff053103" width="200"/> | <img src="https://github.com/user-attachments/assets/8d90edfe-1f10-4e81-acc1-383a4f3bbdf8" width="200"/> | <img src="https://github.com/user-attachments/assets/d84091db-c99c-4508-a851-fe782482306a" width="200"/> | <img src="https://github.com/user-attachments/assets/4f659482-8d10-414f-a734-9fb57fdaba49" width="200"/> | <img src="https://github.com/user-attachments/assets/2155ec37-8107-43e4-9b36-5d2b4c666964" width="200"/> |

---

### 📊 Reports & Settings (Admin)

| Performance Report | Leaderboard | Export Completed Task | Privacy Screen | - |
|--------------------|-------------|------------------------|----------------|---|
| <img src="https://github.com/user-attachments/assets/9a3592bb-74cc-4adc-9520-e7b623641755" width="200"/> | <img src="https://github.com/user-attachments/assets/8c6f9712-2ca7-4c51-973d-c738853318dc" width="200"/> | <img src="https://github.com/user-attachments/assets/695f759b-e607-4368-a1e7-1b1996544286" width="200"/> | <img src="https://github.com/user-attachments/assets/ea71fdb9-11f4-4260-ae47-ae158dff4fee" width="200"/> | - |

---

## 👨‍🎓 Task_Student App  
### 📱 App Screenshots

A focused dashboard for students to manage tasks, view progress, and stay on track.

---

### 🔐 Authentication & Dashboard (Student)

| Loading Screen | Student Login | Home Page | Dashboard | Progress Chart |
|----------------|---------------|-----------|-----------|----------------|
| <img src="https://github.com/user-attachments/assets/7575de7a-356f-4883-bcb7-90defc0a1123" width="200"/> | <img src="https://github.com/user-attachments/assets/68a00605-f447-445e-96ae-866704493fd3" width="200"/> | <img src="https://github.com/user-attachments/assets/bd4fe4e6-69a9-4eb5-9556-57b98c4d29af" width="200"/> | <img src="https://github.com/user-attachments/assets/bd946831-a54f-4ead-92b4-79e5131fa3bd" width="200"/> | <img src="https://github.com/user-attachments/assets/20cd235a-7caf-40a7-9a7d-b09fb28c5579" width="200"/> |

---

### 📊 Tools & Preferences (Student)

| Calendar | Chat with Admin | Settings Screen | Privacy Policy | - |
|----------|------------------|------------------|------------------|---|
| <img src="https://github.com/user-attachments/assets/36eb3f53-15a1-43ac-a6cf-a6462437d664" width="200"/> | <img src="https://github.com/user-attachments/assets/41ece79f-2f96-427a-bd24-d211704b31db" width="200"/> | <img src="https://github.com/user-attachments/assets/a7e920e5-d949-4950-b660-c1afc0d88ab7" width="200"/> | <img src="https://github.com/user-attachments/assets/e1f9ef82-6099-4080-a144-ce40535281f4" width="200"/> | - |
















