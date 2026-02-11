import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'assignments_screen.dart';
import 'announcements_screen.dart';
import 'risk_status_screen.dart';

/// Sessions Screen for managing academic sessions
class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen>
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

  Future<void> _addSession() async {
    final result = await showDialog<Session>(
      context: context,
      builder: (context) => const AddSessionDialog(),
    );

    if (result != null) {
      setState(() => _sessions.add(result));
      await _storageService.saveSessions(_sessions);
    }
  }

  Future<void> _toggleAttendance(Session session) async {
    final updatedSession = session.copyWith(
      attended: !session.attended,
    );
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      setState(() => _sessions[index] = updatedSession);
      await _storageService.saveSessions(_sessions);
    }
  }

  Future<void> _deleteSession(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: ALUColors.warning),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _sessions.removeWhere((s) => s.id == session.id));
      await _storageService.saveSessions(_sessions);
    }
  }

  Future<void> _editSession(Session session) async {
    final result = await showDialog<Session>(
      context: context,
      builder: (context) => EditSessionDialog(session: session),
    );

    if (result != null) {
      final index = _sessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        setState(() => _sessions[index] = result);
        await _storageService.saveSessions(_sessions);
      }
    }
  }

  Widget _buildSessionList(List<Session> sessions) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No sessions found.'));
    }

    // Sort by date
    sessions.sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final bool isToday = session.date.year == DateTime.now().year &&
            session.date.month == DateTime.now().month &&
            session.date.day == DateTime.now().day;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isToday ? ALUColors.primary.withValues(alpha: 0.05) : null,
          child: ExpansionTile(
            title: Text(
              session.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: session.attended ? ALUColors.primary : ALUColors.warning,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${session.date.toString().split(' ')[0]} • ${session.startTime} - ${session.endTime}',
                ),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, color: ALUColors.primary),
                  onPressed: () => _editSession(session),
                  tooltip: 'Edit Session',
                ),
                // Attendance toggle
                IconButton(
                  icon: Icon(
                    session.attended ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: session.attended ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => _toggleAttendance(session),
                  tooltip: session.attended ? 'Mark as Absent' : 'Mark as Present',
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: ALUColors.warning),
                  onPressed: () => _deleteSession(session),
                  tooltip: 'Delete Session',
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text('${session.startTime} - ${session.endTime}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Text(session.location.isNotEmpty
                            ? session.location
                            : 'No location specified'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category, size: 16),
                        const SizedBox(width: 8),
                        Text('Session Type: ${session.type}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.assignment_ind, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Status: ${session.attended ? '✅ Attended' : '❌ Absent'}',
                          style: TextStyle(
                            color: session.attended ? Colors.green : ALUColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Session> get _upcomingSessions {
    final now = DateTime.now();
    return _sessions.where((session) {
      return session.date.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Sessions'),
        backgroundColor: ALUColors.primary,
        foregroundColor: ALUColors.background,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addSession),
        ],
      ),
      body: Column(
        children: [
          // Weekly Schedule Summary
          Card(
            margin: const EdgeInsets.all(16),
            color: ALUColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'This Week\'s Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_upcomingSessions.length} upcoming sessions',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'All Sessions'),
            ],
            labelColor: ALUColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: ALUColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming sessions
                _buildSessionList(_upcomingSessions),
                // All sessions
                _buildSessionList(_sessions),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Updated index for sessions
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
              // Already on sessions
              break;
            case 4:
              Navigator.of(context).pushReplacement(
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

/// Dialog for adding new sessions
class AddSessionDialog extends StatefulWidget {
  const AddSessionDialog({super.key});

  @override
  State<AddSessionDialog> createState() => _AddSessionDialogState();
}

class _AddSessionDialogState extends State<AddSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  String _selectedType = 'Class';

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Academic Session'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a session title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'e.g., Room 101, Online',
                ),
              ),
              const SizedBox(height: 16),
              // Date selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDate.toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              // Start time selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start Time: ${_formatTimeOfDay(_startTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectStartTime(context),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              // End time selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'End Time: ${_formatTimeOfDay(_endTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectEndTime(context),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Session type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Session Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Class',
                    child: Text('Class'),
                  ),
                  DropdownMenuItem(
                    value: 'Mastery Session',
                    child: Text('Mastery Session'),
                  ),
                  DropdownMenuItem(
                    value: 'Study Group',
                    child: Text('Study Group'),
                  ),
                  DropdownMenuItem(
                    value: 'PSL Meeting',
                    child: Text('PSL Meeting'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final session = Session(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                date: _selectedDate,
                startTime: _formatTimeOfDay(_startTime),
                endTime: _formatTimeOfDay(_endTime),
                location: _locationController.text.trim(),
                type: _selectedType,
                attended: false,
              );
              Navigator.of(context).pop(session);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ALUColors.primary,
            foregroundColor: ALUColors.background,
          ),
          child: const Text('Add Session'),
        ),
      ],
    );
  }
}

/// Dialog for editing existing sessions
class EditSessionDialog extends StatefulWidget {
  final Session session;

  const EditSessionDialog({super.key, required this.session});

  @override
  State<EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<EditSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session.title);
    _locationController = TextEditingController(text: widget.session.location);
    _selectedDate = widget.session.date;
    _startTime = _parseTimeOfDay(widget.session.startTime);
    _endTime = _parseTimeOfDay(widget.session.endTime);
    _selectedType = widget.session.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Academic Session'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a session title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'e.g., Room 101, Online',
                ),
              ),
              const SizedBox(height: 16),
              // Date selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDate.toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              // Start time selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start Time: ${_formatTimeOfDay(_startTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectStartTime(context),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              // End time selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'End Time: ${_formatTimeOfDay(_endTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectEndTime(context),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Session type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Session Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'Class',
                    child: Text('Class'),
                  ),
                  DropdownMenuItem(
                    value: 'Mastery Session',
                    child: Text('Mastery Session'),
                  ),
                  DropdownMenuItem(
                    value: 'Study Group',
                    child: Text('Study Group'),
                  ),
                  DropdownMenuItem(
                    value: 'PSL Meeting',
                    child: Text('PSL Meeting'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final session = Session(
                id: widget.session.id,
                title: _titleController.text.trim(),
                date: _selectedDate,
                startTime: _formatTimeOfDay(_startTime),
                endTime: _formatTimeOfDay(_endTime),
                location: _locationController.text.trim(),
                type: _selectedType,
                attended: widget.session.attended,
              );
              Navigator.of(context).pop(session);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ALUColors.primary,
            foregroundColor: ALUColors.background,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

