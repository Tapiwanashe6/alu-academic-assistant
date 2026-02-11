import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'assignments_screen.dart';
import 'announcements_screen.dart';
import 'sessions_screen.dart';
import 'risk_status_screen.dart';

/// Dashboard Screen showing today's overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storageService = StorageService();
  User? _user;
  List<Assignment> _assignments = [];
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _storageService.loadUser();

      // Initialize default data if it doesn't exist
      await _storageService.initializeDefaultAssignments();
      await _storageService.initializeDefaultSessions();
      await _storageService.initializeDefaultAnnouncements();

      // Load the data
      final assignments = await _storageService.loadAssignments();
      final sessions = await _storageService.loadSessions();

      if (mounted) {
        setState(() {
          _user = user;
          _assignments = assignments;
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Calculate current academic week (simplified)
  int get _currentAcademicWeek {
    final now = DateTime.now();
    // Assuming semester starts from some reference date (e.g., Jan 15, 2024)
    final semesterStart = DateTime(2024, 1, 15);
    final daysSinceStart = now.difference(semesterStart).inDays;
    return (daysSinceStart / 7).floor() + 1;
  }

  /// Format today's date
  String get _formattedDate {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  List<Assignment> get _assignmentsDueInSevenDays {
    final today = DateTime.now();
    final sevenDaysFromNow = today.add(const Duration(days: 7));
    return _assignments.where((assignment) {
      return !assignment.isCompleted &&
          assignment.dueDate.isAfter(today) &&
          assignment.dueDate.isBefore(sevenDaysFromNow.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<Session> get _todaySessions {
    final today = DateTime.now();
    return _sessions.where((session) {
      return session.date.year == today.year &&
          session.date.month == today.month &&
          session.date.day == today.day;
    }).toList();
  }

  int get _pendingAssignments =>
      _assignments.where((a) => !a.isCompleted).length;

  double get _attendancePercentage {
    if (_sessions.isEmpty) return 0.0;
    final attendedCount = _sessions.where((session) => session.attended).length;
    return (attendedCount / _sessions.length) * 100;
  }

  bool get _isAttendanceLow => _attendancePercentage < ALUConstants.safeThreshold;

  Color get _attendanceColor {
    if (_attendancePercentage >= ALUConstants.safeThreshold) {
      return ALUColors.primary;
    } else if (_attendancePercentage >= ALUConstants.warningThreshold) {
      return ALUColors.accent;
    } else {
      return ALUColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      // Redirect to signup if no user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/signup');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(ALUConstants.dashboardTitle),
        backgroundColor: ALUColors.primary,
        foregroundColor: ALUColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and academic week
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_user!.name}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      _formattedDate,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Card(
                  color: ALUColors.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Week $_currentAcademicWeek',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ALUColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Stats Row
            Row(
              children: [
                // Pending Assignments Card
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            _pendingAssignments.toString(),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: ALUColors.primary),
                          ),
                          const Text('Pending Assignments'),
                          const SizedBox(height: 4),
                          Text(
                            'Due this week: ${_assignmentsDueInSevenDays.length}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Attendance Card with Warning
                Expanded(
                  child: Stack(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${_attendancePercentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.headlineMedium
                                    ?.copyWith(color: _attendanceColor),
                              ),
                              const Text('Attendance'),
                            ],
                          ),
                        ),
                      ),
                      // Visual warning indicator when attendance is low
                      if (_isAttendanceLow)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: ALUColors.warning,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Today's Sessions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Sessions",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_todaySessions.isNotEmpty)
                  Text(
                    '${_todaySessions.length} sessions',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _todaySessions.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No sessions scheduled for today',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _todaySessions.length,
                      itemBuilder: (context, index) {
                        final session = _todaySessions[index];
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: session.attended
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : ALUColors.warning.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                session.attended ? Icons.check : Icons.schedule,
                                color: session.attended ? Colors.green : ALUColors.warning,
                              ),
                            ),
                            title: Text(session.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${session.startTime} - ${session.endTime}'),
                                if (session.location.isNotEmpty)
                                  Text(
                                    '📍 ${session.location}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                Text(
                                  'Type: ${session.type}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              session.attended
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: session.attended
                                  ? Colors.green
                                  : ALUColors.warning,
                            ),
                            onTap: () {
                              // Navigate to sessions screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SessionsScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Assignments Due in Next 7 Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Assignments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_assignmentsDueInSevenDays.isNotEmpty)
                  Text(
                    '(${_assignmentsDueInSevenDays.length} due soon)',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _assignmentsDueInSevenDays.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_turned_in,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No assignments due in the next 7 days',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _assignmentsDueInSevenDays.length,
                      itemBuilder: (context, index) {
                        final assignment = _assignmentsDueInSevenDays[index];
                        final daysUntilDue = assignment.dueDate
                            .difference(DateTime.now())
                            .inDays;
                        
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: assignment.priority == ALUConstants.highPriority
                                    ? ALUColors.warning.withValues(alpha: 0.1)
                                    : ALUColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                assignment.priority == ALUConstants.highPriority
                                    ? Icons.priority_high
                                    : Icons.assignment,
                                color: assignment.priority == ALUConstants.highPriority
                                    ? ALUColors.warning
                                    : ALUColors.primary,
                              ),
                            ),
                            title: Text(assignment.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(assignment.course),
                                Text(
                                  'Due: ${assignment.dueDate.toString().split(' ')[0]}',
                                  style: TextStyle(
                                    color: daysUntilDue <= 2
                                        ? ALUColors.warning
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              assignment.isCompleted
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: assignment.isCompleted
                                  ? ALUColors.primary
                                  : ALUColors.warning,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AssignmentsScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AssignmentsScreen(),
                ),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsScreen(),
                ),
              );
              break;
            case 3:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SessionsScreen(),
                ),
              );
              break;
            case 4:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RiskStatusScreen(),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: ALUConstants.dashboardNav,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: ALUConstants.assignmentsNav,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: ALUConstants.announcementsNav,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: ALUConstants.riskStatusNav,
          ),
        ],
        selectedItemColor: ALUColors.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

