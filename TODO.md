# TODO: Align Code with Rubric Requirements

## Phase 1: Model Updates
- [x] Update Assignment model to add `course` field
- [x] Update Session model to add `location` field  
- [x] Update Assignment model JSON serialization
- [x] Update Session model JSON serialization

## Phase 2: Assignment Improvements
- [x] Update AddAssignmentDialog to include Course Name field
- [x] Update Assignment list item to display course name
- [x] Add Edit assignment functionality
- [x] Update default assignments to include course names

## Phase 3: Session Management System
- [x] Create Sessions Screen (full CRUD functionality)
- [x] Add session creation dialog with:
  - Session title (required)
  - Date picker
  - Start time picker
  - End time picker
  - Location field (optional)
  - Session type dropdown (Class, Mastery Session, Study Group, PSL Meeting)
  - Present/Absent toggle for attendance
- [x] Add edit session functionality
- [x] Add delete session functionality
- [x] Display weekly schedule on sessions screen

## Phase 4: Dashboard Enhancements  
- [x] Calculate and display current academic week
- [x] Add assignments due within next 7 days section
- [x] Calculate and display overall attendance percentage
- [x] Add visual warning indicator when attendance < 75%
- [x] Add pending assignments summary count
- [x] Update bottom navigation to include Sessions tab

## Phase 5: Risk Status Updates
- [x] Update RiskStatusScreen to show visual alerts for low attendance
- [x] Add attendance history display
- [x] Add recommendations based on attendance patterns

## Phase 6: Storage Service Updates
- [x] Update storage service for new model fields
- [x] Initialize sample sessions with location and proper types
- [x] Update default assignments with course names

## Phase 7: Edit Functionality (COMPLETED)
- [x] Add EditAssignmentDialog to assignments_screen.dart
- [x] Add EditSessionDialog to sessions_screen.dart

## Phase 8: Attendance History (COMPLETED)
- [x] Add attendance history section to RiskStatusScreen
- [x] Display past sessions with attendance status
- [x] Show attendance trends and patterns

## Phase 9: Testing & Validation
- [ ] Test assignment creation with course field
- [ ] Test session creation and management
- [ ] Test dashboard calculations
- [ ] Test attendance tracking
- [ ] Verify all features work together

## ✅ ALL RUBRIC REQUIREMENTS COMPLETED

### Summary of Implementation:

1. **Home Dashboard** ✅
   - Today's date and current academic week
   - List of today's scheduled academic sessions
   - Assignments due within the next seven days
   - Current overall attendance percentage
   - Visual warning indicator when attendance falls below 75%
   - Summary count of pending assignments

2. **Assignment Management System** ✅
   - Create new assignments with title, due date, course name, priority
   - View all assignments sorted by due date
   - Mark assignments as completed with check action
   - Remove assignments from the list
   - Edit assignment details

3. **Academic Session Scheduling** ✅
   - Schedule new academic sessions with title, date, start/end time, location, session type
   - View weekly schedule displaying all sessions
   - Record attendance for each session using Present/Absent toggle
   - Remove scheduled sessions when cancelled
   - Modify session details

4. **Attendance Tracking** ✅
   - Calculate attendance percentage automatically
   - Display attendance metrics clearly on the dashboard
   - Provide alerts when attendance drops below 75%
   - Maintain attendance history for reference
   - Show attendance trends and patterns
   - Provide recommendations based on attendance

