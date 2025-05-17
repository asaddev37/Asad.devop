

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
📸 Supabase Screenshots (Compact Table View)
<table> <tr align="center"> <th>📊 Schema Visualizer</th> <th>👤 Users Table</th> <th>🗃️ Database Tables</th> </tr> <tr> <td><img width="300" src="https://github.com/user-attachments/assets/6225cce8-05b9-46a5-970a-b0442d51f298" /></td> <td><img width="300" src="https://github.com/user-attachments/assets/3669d782-b359-4ab1-8cba-ac073ee3bf1c" /></td> <td><img width="300" src="https://github.com/user-attachments/assets/1a044baf-477b-4e05-bd4a-df606a1cfe89" /></td> </tr> </table>





