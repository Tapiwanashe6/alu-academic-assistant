import 'package:flutter/material.dart';

/// ALU Academic Assistant App Constants
/// Contains colors, themes, and app-wide constants

class ALUColors {
  // Primary ALU Blue
  static const Color primary = Color(0xFF003366);

  // Accent Yellow for warnings
  static const Color accent = Color(0xFFFFC107);

  // Warning Red for alerts
  static const Color warning = Color(0xFFCC0000);

  // Clean White
  static const Color background = Color(0xFFFFFFFF);
}

class ALUConstants {
  // App Title
  static const String appTitle = 'ALU Academic Assistant';

  // Screen Titles
  static const String signupTitle = 'Student Registration';
  static const String dashboardTitle = 'Dashboard';
  static const String assignmentsTitle = 'Assignments';
  static const String announcementsTitle = 'Announcements';
  static const String riskStatusTitle = 'Risk Status';

  // Navigation Labels
  static const String dashboardNav = 'Dashboard';
  static const String assignmentsNav = 'Assignments';
  static const String announcementsNav = 'Announcements';
  static const String riskStatusNav = 'Risk Status';

  // Form Labels
  static const String nameLabel = 'Full Name';
  static const String emailLabel = 'Email Address';
  static const String studentIdLabel = 'Student ID';
  static const String programLabel = 'Program';
  static const String submitButton = 'Register';

  // Assignment Priorities
  static const String lowPriority = 'Low';
  static const String mediumPriority = 'Medium';
  static const String highPriority = 'High';

  // Risk Status Messages
  static const String safeStatus = 'Safe Zone';
  static const String warningStatus = 'Warning Zone';
  static const String atRiskStatus = 'At Risk';

  // Attendance Thresholds
  static const double safeThreshold = 75.0;
  static const double warningThreshold = 50.0;
}
