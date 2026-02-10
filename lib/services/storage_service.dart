import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../models/announcement.dart';

/// Storage service for persisting app data using SharedPreferences
class StorageService {
  static const String _userKey = 'user';
  static const String _assignmentsKey = 'assignments';
  static const String _sessionsKey = 'sessions';
  static const String _announcementsKey = 'announcements';

  /// Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // User Storage Methods

  /// Save user data
  Future<void> saveUser(User user) async {
    final prefs = await _getPrefs();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// Load user data
  Future<User?> loadUser() async {
    final prefs = await _getPrefs();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Clear user data
  Future<void> clearUser() async {
    final prefs = await _getPrefs();
    await prefs.remove(_userKey);
  }

  // Assignment Storage Methods

  /// Save assignments list
  Future<void> saveAssignments(List<Assignment> assignments) async {
    final prefs = await _getPrefs();
    final assignmentsJson = jsonEncode(
      assignments.map((assignment) => assignment.toJson()).toList(),
    );
    await prefs.setString(_assignmentsKey, assignmentsJson);
  }

  /// Load assignments list
  Future<List<Assignment>> loadAssignments() async {
    final prefs = await _getPrefs();
    final assignmentsJson = prefs.getString(_assignmentsKey);
    if (assignmentsJson == null) return [];

    try {
      final assignmentsList = jsonDecode(assignmentsJson) as List<dynamic>;
      return assignmentsList
          .map((item) => Assignment.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear assignments data
  Future<void> clearAssignments() async {
    final prefs = await _getPrefs();
    await prefs.remove(_assignmentsKey);
  }

  // Session Storage Methods

  /// Save sessions list
  Future<void> saveSessions(List<Session> sessions) async {
    final prefs = await _getPrefs();
    final sessionsJson = jsonEncode(
      sessions.map((session) => session.toJson()).toList(),
    );
    await prefs.setString(_sessionsKey, sessionsJson);
  }

  /// Load sessions list
  Future<List<Session>> loadSessions() async {
    final prefs = await _getPrefs();
    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson == null) return [];

    try {
      final sessionsList = jsonDecode(sessionsJson) as List<dynamic>;
      return sessionsList
          .map((item) => Session.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear sessions data
  Future<void> clearSessions() async {
    final prefs = await _getPrefs();
    await prefs.remove(_sessionsKey);
  }

  // Announcement Storage Methods

  /// Save announcements list
  Future<void> saveAnnouncements(List<Announcement> announcements) async {
    final prefs = await _getPrefs();
    final announcementsJson = jsonEncode(
      announcements.map((announcement) => announcement.toJson()).toList(),
    );
    await prefs.setString(_announcementsKey, announcementsJson);
  }

  /// Load announcements list
  Future<List<Announcement>> loadAnnouncements() async {
    final prefs = await _getPrefs();
    final announcementsJson = prefs.getString(_announcementsKey);
    if (announcementsJson == null) return [];

    try {
      final announcementsList = jsonDecode(announcementsJson) as List<dynamic>;
      return announcementsList
          .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear announcements data
  Future<void> clearAnnouncements() async {
    final prefs = await _getPrefs();
    await prefs.remove(_announcementsKey);
  }

  /// Clear all data
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  /// Initialize default assignments if none exist
  Future<void> initializeDefaultAssignments() async {
    final existingAssignments = await loadAssignments();
    if (existingAssignments.isEmpty) {
      final defaultAssignments = [
        // Formative assignments (quizzes, activities)
        Assignment(
          id: 'formative_1',
          title: 'Flutter Widgets Quiz',
          description:
              'Complete the online quiz on Flutter widgets and state management concepts.',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          priority: 'High',
          type: 'formative',
          hasReminder: true,
        ),
        Assignment(
          id: 'formative_2',
          title: 'Database Design Activity',
          description:
              'Create an ER diagram for a student management system as a group activity.',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          priority: 'Medium',
          type: 'formative',
          hasReminder: false,
        ),
        Assignment(
          id: 'formative_3',
          title: 'Code Review Exercise',
          description:
              'Review and provide feedback on a peer\'s Flutter application code.',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          priority: 'Medium',
          type: 'formative',
          hasReminder: true,
        ),
        // Summative assignments (exams, major projects)
        Assignment(
          id: 'summative_1',
          title: 'Final Flutter Project',
          description:
              'Develop a complete mobile application using Flutter with full functionality.',
          dueDate: DateTime.now().add(const Duration(days: 21)),
          priority: 'High',
          type: 'summative',
          hasReminder: true,
        ),
        Assignment(
          id: 'summative_2',
          title: 'Database Systems Exam',
          description:
              'Prepare for the comprehensive database systems examination covering SQL, normalization, and database design.',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          priority: 'High',
          type: 'summative',
          hasReminder: true,
        ),
        Assignment(
          id: 'summative_3',
          title: 'Software Engineering Project',
          description:
              'Complete the semester-long software engineering project with documentation and presentation.',
          dueDate: DateTime.now().add(const Duration(days: 28)),
          priority: 'High',
          type: 'summative',
          hasReminder: true,
        ),
      ];
      await saveAssignments(defaultAssignments);
    }
  }

  /// Initialize default sessions if none exist
  Future<void> initializeDefaultSessions() async {
    final existingSessions = await loadSessions();
    if (existingSessions.isEmpty) {
      final now = DateTime.now();
      final defaultSessions = [
        // Recent sessions with mixed attendance
        Session(
          id: 'session_1',
          title: 'Flutter Development Lecture',
          date: now.subtract(const Duration(days: 1)),
          startTime: '09:00',
          endTime: '10:30',
          type: 'Lecture',
          attended: true,
        ),
        Session(
          id: 'session_2',
          title: 'Database Systems Tutorial',
          date: now.subtract(const Duration(days: 2)),
          startTime: '11:00',
          endTime: '12:30',
          type: 'Tutorial',
          attended: true,
        ),
        Session(
          id: 'session_3',
          title: 'Software Engineering Lab',
          date: now.subtract(const Duration(days: 3)),
          startTime: '14:00',
          endTime: '16:00',
          type: 'Lab',
          attended: false, // Missed session
        ),
        Session(
          id: 'session_4',
          title: 'Web Development Workshop',
          date: now.subtract(const Duration(days: 4)),
          startTime: '10:00',
          endTime: '11:30',
          type: 'Workshop',
          attended: true,
        ),
        Session(
          id: 'session_5',
          title: 'Mobile App Design Seminar',
          date: now.subtract(const Duration(days: 5)),
          startTime: '13:00',
          endTime: '14:30',
          type: 'Seminar',
          attended: true,
        ),
        Session(
          id: 'session_6',
          title: 'Data Structures Lecture',
          date: now.subtract(const Duration(days: 6)),
          startTime: '09:00',
          endTime: '10:30',
          type: 'Lecture',
          attended: false, // Missed session
        ),
        Session(
          id: 'session_7',
          title: 'Algorithm Analysis Tutorial',
          date: now.subtract(const Duration(days: 7)),
          startTime: '15:00',
          endTime: '16:30',
          type: 'Tutorial',
          attended: true,
        ),
        // Upcoming sessions
        Session(
          id: 'session_8',
          title: 'Final Project Presentation',
          date: now.add(const Duration(days: 2)),
          startTime: '10:00',
          endTime: '12:00',
          type: 'Presentation',
          attended: false, // Not yet attended
        ),
        Session(
          id: 'session_9',
          title: 'Exam Preparation Session',
          date: now.add(const Duration(days: 5)),
          startTime: '14:00',
          endTime: '16:00',
          type: 'Study Session',
          attended: false, // Not yet attended
        ),
      ];
      await saveSessions(defaultSessions);
    }
  }

  /// Initialize default announcements if none exist
  Future<void> initializeDefaultAnnouncements() async {
    final existingAnnouncements = await loadAnnouncements();
    if (existingAnnouncements.isEmpty) {
      final defaultAnnouncements = [
        Announcement(
          id: 'announcement_1',
          title: 'Welcome to ALU Academic Assistant',
          content:
              'Welcome to the ALU Academic Assistant app! This tool will help you manage your assignments, track attendance, and stay on top of university announcements.',
          date: DateTime.now(),
          priority: 'High',
        ),
        Announcement(
          id: 'announcement_2',
          title: 'Mid-Semester Break',
          content:
              'The mid-semester break will begin next week. Please ensure all assignments are submitted before the break starts.',
          date: DateTime.now().add(const Duration(days: 5)),
          priority: 'Medium',
        ),
        Announcement(
          id: 'announcement_3',
          title: 'Library Hours Extended',
          content:
              'The university library will have extended hours during exam period. Check the library website for updated schedules.',
          date: DateTime.now().add(const Duration(days: 10)),
          priority: 'Low',
        ),
      ];
      await saveAnnouncements(defaultAnnouncements);
    }
  }
}
