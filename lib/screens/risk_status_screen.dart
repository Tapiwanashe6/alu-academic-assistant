import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'assignments_screen.dart';
import 'announcements_screen.dart';
import 'sessions_screen.dart';

/// Risk Status Screen showing attendance percentage, risk level, and history
class RiskStatusScreen extends StatefulWidget {
  const RiskStatusScreen({super.key});

  @override
  State<RiskStatusScreen> createState() => _RiskStatusScreenState();
}

class _RiskStatusScreenState extends State<RiskStatusScreen>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  List<Session> _sessions = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _storageService.loadSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _attendancePercentage {
    if (_sessions.isEmpty) return 0.0;
    final attendedCount = _sessions.where((session) => session.attended).length;
    return (attendedCount / _sessions.length) * 100;
  }

  Color get _riskColor {
    final percentage = _attendancePercentage;
    if (percentage >= ALUConstants.safeThreshold) {
      return ALUColors.primary; // Blue = Safe
    } else if (percentage >= ALUConstants.warningThreshold) {
      return ALUColors.accent; // Yellow = Warning
    } else {
      return ALUColors.warning; // Red = At Risk
    }
  }

  String get _riskStatus {
    final percentage = _attendancePercentage;
    if (percentage >= ALUConstants.safeThreshold) {
      return ALUConstants.safeStatus;
    } else if (percentage >= ALUConstants.warningThreshold) {
      return ALUConstants.warningStatus;
    } else {
      return ALUConstants.atRiskStatus;
    }
  }

  List<Session> get _recentSessions {
    final now = DateTime.now();
    return _sessions
        .where((session) =>
            session.date.isAfter(now.subtract(const Duration(days: 30))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Session> get _attendedSessions =>
      _sessions.where((session) => session.attended).toList();

  List<Session> get _missedSessions =>
      _sessions.where((session) => !session.attended).toList();

  String _getRecommendation() {
    final percentage = _attendancePercentage;
    final missedCount = _missedSessions.length;

    if (percentage >= ALUConstants.safeThreshold) {
      return "Great job! Your attendance is excellent. Keep up the consistent work to maintain your academic performance.";
    } else if (percentage >= ALUConstants.warningThreshold) {
      if (missedCount > 0) {
        return "Your attendance is in the warning zone. Try to attend all remaining sessions to improve your standing. Focus on upcoming classes and consider setting reminders.";
      }
      return "You're close to the safe zone. Make sure to attend all future sessions.";
    } else {
      return "Your attendance is critically low. This puts you at significant academic risk. Please speak with your academic advisor immediately and commit to attending every remaining session.";
    }
  }

  List<String> _getAttendanceTrends() {
    final trends = <String>[];
    final recent = _recentSessions;
    final attendedRecent =
        recent.where((s) => s.attended).length;

    if (recent.isEmpty) {
      trends.add("No recent sessions recorded");
      return trends;
    }

    final recentPercentage =
        (attendedRecent / recent.length * 100).round();

    if (recentPercentage >= 80) {
      trends.add("📈 Recent attendance trend: Improving");
    } else if (recentPercentage >= 60) {
      trends.add("📊 Recent attendance trend: Stable");
    } else {
      trends.add("📉 Recent attendance trend: Declining");
    }

    // Count missed by type
    final missedByType = <String, int>{};
    for (final session in _missedSessions) {
      missedByType[session.type] = (missedByType[session.type] ?? 0) + 1;
    }

    if (missedByType.isNotEmpty) {
      final worstType = missedByType.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      trends.add("Most missed: ${worstType.key} (${worstType.value} times)");
    }

    return trends;
  }

  Widget _buildAttendanceGauge() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _riskColor.withValues(alpha: 0.1),
        border: Border.all(color: _riskColor, width: 4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_attendancePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _riskColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance Rate',
              style: TextStyle(fontSize: 16, color: _riskColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Session Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      _sessions.length.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total Sessions'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _attendedSessions.length.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Attended'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      _missedSessions.length.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text('Missed'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: ALUColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getRecommendation(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ..._getAttendanceTrends().map((trend) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(trend),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    final sortedSessions = List<Session>.from(_sessions)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (sortedSessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No session history available'),
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        final session = sortedSessions[index];
        final isMissed = !session.attended;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isMissed
              ? ALUColors.warning.withValues(alpha: 0.05)
              : Colors.green.withValues(alpha: 0.05),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isMissed
                    ? ALUColors.warning.withValues(alpha: 0.2)
                    : Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMissed ? Icons.close : Icons.check,
                color: isMissed ? ALUColors.warning : Colors.green,
              ),
            ),
            title: Text(session.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.date.toString().split(' ')[0]} • ${session.startTime} - ${session.endTime}',
                ),
                Text(
                  'Type: ${session.type}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              session.attended ? 'Present' : 'Absent',
              style: TextStyle(
                color: session.attended ? Colors.green : ALUColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(ALUConstants.riskStatusTitle),
        backgroundColor: ALUColors.primary,
        foregroundColor: ALUColors.background,
      ),
      body: Column(
        children: [
          // Tab Bar for Overview and History
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'History'),
            ],
            labelColor: ALUColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: ALUColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Attendance Percentage Display
                      _buildAttendanceGauge(),
                      const SizedBox(height: 32),

                      // Risk Status
                      Text(
                        _riskStatus,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _riskColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sessions Summary
                      _buildSessionSummary(),
                      const SizedBox(height: 16),

                      // Recommendations
                      _buildRecommendations(),
                      const SizedBox(height: 16),

                      // Risk Thresholds Info
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk Thresholds',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Safe Zone: ≥${ALUConstants.safeThreshold.toInt()}% attendance',
                                style: const TextStyle(color: Color(0xFF003366)),
                              ),
                              Text(
                                '• Warning Zone: ${ALUConstants.warningThreshold.toInt()}% - ${ALUConstants.safeThreshold.toInt()}% attendance',
                                style: const TextStyle(color: Color(0xFFFFC107)),
                              ),
                              Text(
                                '• At Risk: <${ALUConstants.warningThreshold.toInt()}% attendance',
                                style: const TextStyle(color: Color(0xFFCC0000)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // History Tab
                Column(
                  children: [
                    // History Summary
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Chip(
                            label: Text('Total: ${_sessions.length}'),
                            backgroundColor: ALUColors.primary.withValues(alpha: 0.1),
                          ),
                          Chip(
                            label: Text('Present: ${_attendedSessions.length}'),
                            backgroundColor: Colors.green.withValues(alpha: 0.1),
                          ),
                          Chip(
                            label: Text('Absent: ${_missedSessions.length}'),
                            backgroundColor: ALUColors.warning.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildAttendanceHistory(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AssignmentsScreen(),
                ),
              );
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsScreen(),
                ),
              );
              break;
            case 3:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SessionsScreen(),
                ),
              );
              break;
            case 4:
              // Already on risk status
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

