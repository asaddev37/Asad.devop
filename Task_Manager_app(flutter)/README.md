# Task Manager App

A feature-rich Flutter application designed to help users manage their tasks efficiently with a clean, customizable interface. The app supports task creation, reminders, categories, dark/light mode, and more.

## Features

### Core Functionality
- ✅ **Task Management**
  - Add, edit, and delete tasks
  - Mark tasks as complete
  - View task details and subtasks
- 🔄 **Recurring Tasks**
  - Create tasks that repeat on specific days
  - Manage all recurring tasks in one place
- 📅 **Upcoming Tasks**
  - View future tasks with sorting options
  - Visual timeline for long-term planning
- 📊 **Progress Tracking**
  - Visual completion metrics
  - Completed tasks history

### Organization
- 🗂 **Categories System**
  - Create custom categories
  - Filter tasks by category
  - Edit/delete categories
- 🔍 **Smart Search**
  - Quickly find any task
  - Filter by various criteria

### Notifications
- ⏰ **Reminders**
  - Set date/time for task notifications
  - Manage all notifications in one screen
  - Persistent across app restarts
- 🔔 **Notification Control**
  - Enable/disable reminders
  - Swipe to cancel individual notifications
  - Bulk clear all notifications

### Customization
- 🌓 **Dark/Light Mode**
  - Toggle between themes
  - Automatic system theme detection
- � **Color Customization**
  - Choose from preset colors
  - Custom accent colors
- 🖌 **UI Personalization**
  - Clean, modern interface
  - Responsive design

### Data Management
- 📤 **Export Options**
  - Share tasks as CSV files
  - Download completed tasks as PDF
- 💾 **Auto-save Drafts**
  - Never lose work in progress

## Technical Details

### Requirements
- Flutter SDK (version 3.0.0 or higher)
- Dart (version 2.17.0 or higher)
- Android/iOS device or emulator
### Models 
- Chat gpt
- Deep Seek
- Grok
- Perplexity

### Dependencies
- `flutter_local_notifications`: For task reminders
- `pdf`: For PDF generation
- `share_plus`: For task sharing functionality
- `provider`: For state management

# Task Manager App  
### 📱 App Screenshots

---

### 🔄 Non-Repeated Tasks

| Loading Screen | Today Task | Dark Mode | Add Task |
|----------------|------------|-----------|----------|
| <img src="https://github.com/user-attachments/assets/282f40dc-7711-44fe-ad5e-e3bea2348f5d" width="200"/> | <img src="https://github.com/user-attachments/assets/0cced6e1-adfb-40e6-8698-21f3511b6979" width="200"/> | <img src="https://github.com/user-attachments/assets/eb444201-5fcf-4dbe-b57a-4f50ec5e27cd" width="200"/> | <img src="https://github.com/user-attachments/assets/794f5382-2b25-4564-9a62-ed0487d99f52" width="200"/> |

| Task Details | Edit Task | Future Tasks | Notifications |
|--------------|-----------|---------------|----------------|
| <img src="https://github.com/user-attachments/assets/4cd9a477-243c-4177-974a-f71db3f2e0ad" width="200"/> | <img src="https://github.com/user-attachments/assets/e0a81b17-c4bd-40b0-bf37-00b261f358ab" width="200"/> | <img src="https://github.com/user-attachments/assets/ceee30a7-213b-479b-90b4-c5ff167907e4" width="200"/> | <img src="https://github.com/user-attachments/assets/756682f3-5cdc-42db-baa6-6756160908ce" width="200"/> |

| Completed Tasks | Notification Popup |
|------------------|---------------------|
| <img src="https://github.com/user-attachments/assets/f9c6755b-2304-4e0c-bdad-ddbd0ecec20e" width="200"/> | <img src="https://github.com/user-attachments/assets/36d8ca99-432f-4ff3-8cb0-7fa372b62cc1" width="200"/> |

---

### 🔁 Repeated Tasks

| Home Screen | Add Task | Task Details | Edit Task |
|-------------|----------|--------------|-----------|
| <img src="https://github.com/user-attachments/assets/6c420eb2-1727-4ee5-a463-107378ec3a1f" width="200"/> | <img src="https://github.com/user-attachments/assets/facb0f69-ae13-4b48-86e0-039d07b7e216" width="200"/> | <img src="https://github.com/user-attachments/assets/a0a2e66b-4530-4251-a1e8-14607ee45d8d" width="200"/> | <img src="https://github.com/user-attachments/assets/9d900719-a840-4349-8bab-474c9e13be5e" width="200"/> |

| Future Tasks | Schedule Notification | Monthly Notification | Notification Received |
|---------------|------------------------|------------------------|------------------------|
| <img src="https://github.com/user-attachments/assets/5cc23146-49bc-43bd-b96a-1ca529ef0693" width="200"/> | <img src="https://github.com/user-attachments/assets/8a9c4668-e17e-46f7-98a9-8573ed89c0e9" width="200"/> | <img src="https://github.com/user-attachments/assets/66625d3a-3736-443e-8056-b681c2cc927c" width="200"/> | <img src="https://github.com/user-attachments/assets/0adf0120-e4c8-42dd-ad8c-49f9ba78f365" width="200"/> |

| Completed Tasks |
|-----------------|
| <img src="https://github.com/user-attachments/assets/226f7533-559e-4dee-9be9-af17da657513" width="200"/> |

---

### 📂 Menu & Settings

| Menu Screen | Features | Guide | Privacy Policy |
|-------------|----------|-------|----------------|
| <img src="https://github.com/user-attachments/assets/2304728a-4c56-4a12-b27a-53b8f5f68d7f" width="200"/> | <img src="https://github.com/user-attachments/assets/a3dd2b0f-7980-4bb0-a243-23ccbc871bd4" width="200"/> | <img src="https://github.com/user-attachments/assets/97531ecb-b77f-445b-95ca-c38c17cdd796" width="200"/> | <img src="https://github.com/user-attachments/assets/c6a71f6d-1828-495c-849f-88a2d6db1316" width="200"/> |

| Settings | Customize Colors | Manage Categories | Coloring Applied |
|----------|------------------|-------------------|------------------|
| <img src="https://github.com/user-attachments/assets/59b9b7dd-eaa8-41d7-9b11-d9ba345054be" width="200"/> | <img src="https://github.com/user-attachments/assets/c260f349-98ae-47fc-a4fb-99d8a9b85631" width="200"/> | <img src="https://github.com/user-attachments/assets/2b82c70c-42b6-467f-b395-caa54851041f" width="200"/> | <img src="https://github.com/user-attachments/assets/e4f7d919-23cb-4661-8ca1-c19339ef60c0" width="200"/> |





