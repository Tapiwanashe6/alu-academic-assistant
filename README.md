# ALU Academic Assistant

ALU Academic Assistant is a Flutter mobile application built to help African Leadership University students manage their academic responsibilities. The app allows students to track assignments, schedule academic sessions, and monitor attendance to reduce missed deadlines and academic stress.

## Core Features
- Dashboard with today’s date, academic week, upcoming sessions, and pending assignments
- Assignment management (create, edit, complete, delete)
- Academic session scheduling with attendance tracking
- Automatic attendance percentage calculation
- Visual warning when attendance drops below 75%
- Clean UI following ALU branding

## Folder Structure
```bash
lib/
├── main.dart
├── models/
│   ├── announcement.dart
│   ├── assignment.dart
│   ├── session.dart
│   └── user.dart
├── screens/
│   ├── announcements_screen.dart
│   ├── assignments_screen.dart
│   ├── dashboard_screen.dart
│   ├── risk_status_screen.dart
│   └── signup_screen.dart
├── services/
│   └── storage_service.dart
└── utils/
```


## How to Run the Project
1. Clone the repository:
```bash
git clone https://github.com/Tapiwanashe6/alu-academic-assistant.git
cd alu-academic-assistant
flutter pub get
flutter run
```
Contributors

Ogayo Andrew Ater – Created core data models (announcement, session, assignment)

Agertu Diriba Aliko – Implemented assignment logic and interactions

Tapiwanashe Gift Marufu – Worked on session scheduling and attendance tracking

Nehemi Ishimwe – Contributed to navigation setup and UI consistency

Olive Umurerwa – Implemented dashboard and risk status UI screens

Course Context

This project was developed as part of the Mobile Application Development course at African Leadership University (ALU).
