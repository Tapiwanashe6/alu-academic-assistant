import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'assignments_screen.dart';
import 'announcements_screen.dart';
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

  List<Assignment> get _todayAssignments {
    final today = DateTime.now();
    return _assignments.where((assignment) {
      return assignment.dueDate.year == today.year &&
          assignment.dueDate.month == today.month &&
          assignment.dueDate.day == today.day;
    }).toList();
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
  int get _attendedSessions => _sessions.where((s) => s.attended).length;

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
            Text(
              'Welcome, ${_user!.name}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Quick Stats
            Row(
              children: [
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            _attendedSessions.toString(),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: ALUColors.primary),
                          ),
                          const Text('Sessions Attended'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Today's Tasks
            Text(
              "Today's Tasks",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _todayAssignments.length,
                itemBuilder: (context, index) {
                  final assignment = _todayAssignments[index];
                  return Card(
                    child: ListTile(
                      title: Text(assignment.title),
                      subtitle: Text(assignment.description),
                      trailing: Icon(
                        assignment.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: assignment.isCompleted
                            ? ALUColors.primary
                            : ALUColors.warning,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Today's Sessions
            Text(
              "Today's Sessions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _todaySessions.length,
                itemBuilder: (context, index) {
                  final session = _todaySessions[index];
                  return Card(
                    child: ListTile(
                      title: Text(session.title),
                      subtitle: Text(
                        '${session.startTime} - ${session.endTime}',
                      ),
                      trailing: Icon(
                        session.attended
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: session.attended
                            ? ALUColors.primary
                            : ALUColors.warning,
                      ),
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