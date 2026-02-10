import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/storage_service.dart';
import 'utils/constants.dart';

void main() {
  runApp(const ALUAcademicAssistant());
}

class ALUAcademicAssistant extends StatelessWidget {
  const ALUAcademicAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ALUConstants.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ALUColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: ALUColors.primary,
          foregroundColor: ALUColors.background,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ALUColors.primary,
            foregroundColor: ALUColors.background,
          ),
        ),
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  bool _hasUser = false;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    try {
      final user = await _storageService.loadUser();
      setState(() {
        _hasUser = user != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasUser = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _hasUser ? const DashboardScreen() : const SignupScreen();
  }
}
