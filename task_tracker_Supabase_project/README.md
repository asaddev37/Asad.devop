

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
# Task_admin App  
### 📱 App Screenshots

| Loading Screen | Login Screen | Admin Dashboard | Student Management | Task Management |
|----------------|--------------|-----------------|--------------------|-----------------|
| <img src="https://github.com/user-attachments/assets/e45b9b3b-9d6a-43b3-ba0d-ef155f6c7129" width="200"/> | <img src="https://github.com/user-attachments/assets/25562e0a-9e47-4744-abb9-0d5b6687b6d9" width="200"/> | <img src="https://github.com/user-attachments/assets/65f94b9b-e19d-4d4b-8fa6-8ab229463e2a" width="200"/> | <img src="https://github.com/user-attachments/assets/53fb3a56-e728-4fd9-b4ca-4832e3372dd1" width="200"/> | <img src="https://github.com/user-attachments/assets/68ac6456-b286-427d-a1c6-4cce47cff0c2" width="200"/> |

| Reports | Leaderboard | Export Screen | Settings | Privacy Screen |
|---------|-------------|---------------|----------|----------------|
| <img src="https://github.com/user-attachments/assets/fd1e88d3-2427-431b-ab4f-63aa685d7484" width="200"/> | <img src="https://github.com/user-attachments/assets/61a03c79-3a2e-4e6f-88da-eda51a435665" width="200"/> | <img src="https://github.com/user-attachments/assets/e2a7d8dc-982a-4105-8bb1-15cf8c41821e" width="200"/> | <img src="https://github.com/user-attachments/assets/d6bfbb66-b43b-4c06-9f4f-6f9e2b384291" width="200"/> | <img src="https://github.com/user-attachments/assets/4c034e9b-ebaa-4343-bac9-4a39cd923d46" width="200"/> |




