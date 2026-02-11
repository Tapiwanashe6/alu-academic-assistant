# ALU Academic Assistant

## Project Purpose
**ALU Academic Assistant** is a Flutter mobile app that helps ALU students manage assignments, schedule academic sessions, track attendance, and stay updated with announcements. It emphasizes clarity, consistency, and ALU branding for a professional academic workflow.

## Key Features
- **Dashboard Overview**: attendance percentage, upcoming sessions, due assignments  
  (see `DashboardScreen`(lib/screens/dashboard_screen.dart))
- **Assignment Management**: create, edit, complete, and filter assignments  
  (see `Assignment`(lib/models/assignment.dart) and [`AssignmentsScreen`](lib/screens/assignments_screen.dart))
- **Session Scheduling**: create/edit sessions, mark attendance, view history  
  (see [`Session`](lib/models/session.dart) and [`SessionsScreen`](lib/screens/sessions_screen.dart))
- **Risk Status**: attendance-based risk status with recommendations  
  (see [`RiskStatusScreen`](lib/screens/risk_status_screen.dart))
- **Announcements**: add and view university announcements  
  (see [`Announcement`](lib/models/announcement.dart) and [`AnnouncementsScreen`](lib/screens/announcements_screen.dart))

## Architecture
The codebase follows a clear separation of **UI**, **models**, and **services**:

- **UI Screens**: lib/screens/lib/screens/
  - `DashboardScreen`lib/screens/dashboard_screen.dart 
  - `AssignmentsScreen`lib/screens/assignments_screen.dart 
  - `SessionsScreen`lib/screens/sessions_screen.dart  
  - `AnnouncementsScreen`lib/screens/announcements_screen.dart  
  - `RiskStatusScreen`lib/screens/risk_status_screen.dart

- **Models**: lib/models/lib/models/ 
  - `Assignment`lib/models/assignment.dart 
  - `Session`lib/models/session.dart
  - `Announcement`lib/models/announcement.dart  
  - `User`lib/models/user.dart

- **Services (Data Layer)**:  
  - `StorageService`lib/services/storage_service.dart uses SharedPreferences for local persistence.

- **App Entry**:  
  - `ALUAcademicAssistant`lib/main.dart

This modular structure enables maintainability and clean separation of concerns.

## Data Persistence
Persistent storage is handled through `StorageService`lib/services/storage_service.dart, which serializes models to JSON and stores them in SharedPreferences.

### Data Flow (Simplified)
1. UI calls `StorageService` for save/load  
2. Models handle JSON serialization/deserialization  
3. UI reflects state updates in screens

## Setup Instructions

### Prerequisites
- Flutter SDK (3.x+)
- Android Studio or VS Code (Flutter + Dart extensions)
- Git

### Install & Run
```sh
git clone <your_hereepo_url>
cd alu-academic-assistant
flutter pub get
flutter run
```

## Contribution Guidelines
- Follow existing naming conventions and formatting.
- Keep UI logic in `screens/`, data logic in `services/`, and data types in `models/`.
- Use meaningful commit messages ( `feat: add session edit dialog`).
- Document design decisions with concise comments when needed.    

## License
This project is for academic use and internal evaluation only.