# ALU Academic Assistant

A Flutter mobile application designed for African Leadership University students to manage their academic life effectively.

## Features

### 1. Student Sign Up
- Registration form with validation
- Stores student profile (name, email, student ID, program)
- Data persists across app restarts

### 2. Dashboard
- Today's date and academic week
- Today's scheduled sessions
- Assignments due within 7 days
- Pending assignments count
- Attendance percentage with low attendance warning (<75%)

### 3. Assignment Management
- **Create**: Add assignments with title, description, due date, course, priority
- **Read**: View all assignments sorted by due date
- **Update**: Edit assignment details, mark as complete
- **Delete**: Swipe left to delete with undo option

### 4. Announcements
- View university announcements
- Expandable cards for full content
- Priority-based styling
- Read and unread status tracking

### 5. Risk Status
- Attendance percentage gauge
- Color-coded risk levels (Green/white/Red)
- Session history with attendance toggle
- Add new sessions with date/time pickers

---

##  Project Structure

```
lib/
├── main.dart                    # App entry point, navigation
├── models/
│   ├── user.dart               # Student data model
│   ├── assignment.dart         # Task data model
│   ├── session.dart            # Academic session model
│   └── announcement.dart       # Announcement model
├── screens/
│   ├── signup_screen.dart      # Registration screen
│   ├── dashboard_screen.dart   # Home overview
│   ├── assignments_screen.dart # Task management
│   ├── announcements_screen.dart
│   └── risk_status_screen.dart # Attendance tracking
├── services/
│   └── storage_service.dart    # SharedPreferences persistence
└── utils/
    └── constants.dart          # colors & enums
```

---

##  ALU Branding

| Color | Hex | Usage |
|-------|-----|-------|
| Blue | `#003366` | AppBar, primary buttons, safe status |
| Red | `#CC0000` | Warnings, risk alerts, delete actions |
| White | `#FFFFFF` | Backgrounds, text on dark surfaces |

---

##  Key Widgets Explained

| Widget | Purpose |
|--------|---------|
| `Scaffold` | Basic app structure with AppBar and body |
| `ListView.builder` | Efficient scrollable list rendering |
| `Card` | Material container with elevation |
| `ListTile` | Standard list item layout |
| `TextFormField` | Input field with validation |
| `DropdownButton` | Selection from list of options |
| `showDatePicker` | Material date picker dialog |
| `showTimePicker` | Material time picker dialog |
| `ExpansionTile` | Expandable content container |
| `Switch` | Toggle for attendance |
| `CircularProgressIndicator` | Progress/loading indicator |
| `BottomNavigationBar` | Tab navigation |
| `IndexedStack` | Preserves screen state when switching tabs |

---

##  State Management

This app uses **StatefulWidget + setState()** pattern:

```dart
// 1. Define state variables
List<Assignment> _assignments = [];

// 2. Update state triggers rebuild
void _handleAssignmentsChanged(List<Assignment> newList) {
  setState(() {
    _assignments = newList;
  });
}

// 3. Pass callbacks to child widgets
AssignmentsScreen(
  assignments: _assignments,
  onAssignmentsChanged: _handleAssignmentsChanged,
)
```

---

## Data Persistence

Using **SharedPreferences** with JSON serialization:

```dart
// SAVE: Object → JSON → String → Storage
Future<void> saveAssignments(List<Assignment> list) async {
  String json = jsonEncode(list.map((a) => a.toJson()).toList());
  await prefs.setString('assignments', json);
}

// LOAD: Storage → String → JSON → Object
Future<List<Assignment>> loadAssignments() async {
  String? data = prefs.getString('assignments');
  if (data == null) return [];
  return (jsonDecode(data) as List)
      .map((json) => Assignment.fromJson(json))
      .toList();
}
```

---

## Attendance Calculation

```dart
double calculateAttendance() {
  if (sessions.isEmpty) return 100.0;
  int attended = sessions.where((s) => s.attended).length;
  return (attended / sessions.length) * 100;
}

// Risk Levels:
// ≥75% = Green (Good Standing)
// 50-74% = Yellow (Warning)  
// <50% = Red (At Risk)
```

---

## Getting Started

### Prerequisites
- Flutter SDK (≥3.0.0)
- Android Studio or VS Code
- Android emulator or physical device

### Installation

```bash
# 1. Navigate to project
cd alu_academic_assistant

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## File Descriptions

| File | Description |
|------|-------------|
| `main.dart` | App initialization, theme setup, navigation controller |
| `constants.dart` | colors, SessionType enum, Priority enum |
| `user.dart` | User model with JSON serialization |
| `assignment.dart` | Assignment model with due date handling |
| `session.dart` | Session model with TimeOfDay handling |
| `announcement.dart` | Announcement model with read status |
| `storage_service.dart` | Singleton service for SharedPreferences |
| `signup_screen.dart` | Form with TextEditingControllers and validation |
| `dashboard_screen.dart` | Overview with filtered lists and stats |
| `assignments_screen.dart` | CRUD with dialogs and Dismissible |
| `announcements_screen.dart` | ExpansionTile list with read tracking |
| `risk_status_screen.dart` | Attendance gauge and session history |

---

## Testing Checklist

- Sign up with valid data
- Add/edit/delete assignments
- Mark assignments as complete
- Add sessions with date/time pickers
- Toggle session attendance
- Verify attendance % updates
- Verify risk status color changes
- Close and reopen app - verify data persists
- Check dashboard shows correct filtered data

---

## Contributing

This project was created for ALU academic purposes. All code is documented with comprehensive comments explaining implementation decisions.

---

##  License

MIT License - Created for African Leadership University
