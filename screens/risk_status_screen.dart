import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Risk Status Screen showing attendance percentage and risk level
class RiskStatusScreen extends StatefulWidget {
  const RiskStatusScreen({super.key});

  @override
  State<RiskStatusScreen> createState() => _RiskStatusScreenState();
}

class _RiskStatusScreenState extends State<RiskStatusScreen> {
  final StorageService _storageService = StorageService();
  List<Session> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ALUConstants.riskStatusTitle),
        backgroundColor: ALUColors.primary,
        foregroundColor: ALUColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Attendance Percentage Display
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _riskColor.withOpacity(0.1),
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
                  ),
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

                  

                  // Risk Thresholds Info
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
    );
  }
}