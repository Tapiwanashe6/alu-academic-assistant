import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';
import 'announcements_screen.dart';
import 'sessions_screen.dart';
import 'risk_status_screen.dart';

/// Assignments Screen for managing tasks
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  List<Assignment> _assignments = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    try {
      final assignments = await _storageService.loadAssignments();
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAssignment() async {
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => const AddAssignmentDialog(),
    );

    if (result != null) {
      setState(() => _assignments.add(result));
      await _storageService.saveAssignments(_assignments);
    }
  }

  Future<void> _toggleAssignmentCompletion(Assignment assignment) async {
    final updatedAssignment = assignment.copyWith(
      isCompleted: !assignment.isCompleted,
    );
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      setState(() => _assignments[index] = updatedAssignment);
      await _storageService.saveAssignments(_assignments);
    }
  }

  Future<void> _editAssignment(Assignment assignment) async {
    final result = await showDialog<Assignment>(
      context: context,
      builder: (context) => EditAssignmentDialog(assignment: assignment),
    );

    if (result != null) {
      final index = _assignments.indexWhere((a) => a.id == assignment.id);
      if (index != -1) {
        setState(() => _assignments[index] = result);
        await _storageService.saveAssignments(_assignments);
      }
    }
  }

  Future<void> _deleteAssignment(Assignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
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
      setState(() => _assignments.removeWhere((a) => a.id == assignment.id));
      await _storageService.saveAssignments(_assignments);
    }
  }

  Widget _buildAssignmentList(List<Assignment> assignments) {
    if (assignments.isEmpty) {
      return const Center(child: Text('No assignments in this category.'));
    }

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return Dismissible(
          key: Key(assignment.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: ALUColors.warning,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => _deleteAssignment(assignment),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                assignment.title,
                style: TextStyle(
                  decoration: assignment.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment.course),
                  const SizedBox(height: 4),
                  Text(assignment.description),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${assignment.dueDate.toString().split(' ')[0]} • Priority: ${assignment.priority} • Type: ${assignment.type}',
                    style: TextStyle(
                      color: assignment.priority == ALUConstants.highPriority
                          ? ALUColors.warning
                          : ALUColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit, color: ALUColors.primary),
                    onPressed: () => _editAssignment(assignment),
                    tooltip: 'Edit Assignment',
                  ),
                  // Checkbox for completion
                  Checkbox(
                    value: assignment.isCompleted,
                    onChanged: (value) => _toggleAssignmentCompletion(assignment),
                    activeColor: ALUColors.primary,
                  ),
                ],
              ),
              onTap: () => _editAssignment(assignment),
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
        title: const Text(ALUConstants.assignmentsTitle),
        backgroundColor: ALUColors.primary,
        foregroundColor: ALUColors.background,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addAssignment),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Formative'),
              Tab(text: 'Summative'),
            ],
            labelColor: ALUColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: ALUColors.primary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All assignments - sorted by due date
                _buildAssignmentList(
                  _assignments..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
                ),
                // Formative assignments - sorted by due date
                _buildAssignmentList(
                  _assignments.where((a) => a.type == 'formative').toList()
                    ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
                ),
                // Summative assignments - sorted by due date
                _buildAssignmentList(
                  _assignments.where((a) => a.type == 'summative').toList()
                    ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
              // Already on assignments
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

/// Dialog for adding new assignments
class AddAssignmentDialog extends StatefulWidget {
  const AddAssignmentDialog({super.key});

  @override
  State<AddAssignmentDialog> createState() => _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends State<AddAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedPriority = ALUConstants.mediumPriority;
  String _selectedType = 'formative';
  bool _hasReminder = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Assignment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${_selectedDate.toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items:
                    [
                      ALUConstants.lowPriority,
                      ALUConstants.mediumPriority,
                      ALUConstants.highPriority,
                    ].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'formative',
                    child: Text('Formative'),
                  ),
                  DropdownMenuItem(
                    value: 'summative',
                    child: Text('Summative'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Set Reminder'),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() => _hasReminder = value ?? false);
                },
                activeColor: ALUColors.primary,
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
              final assignment = Assignment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                course: _courseController.text.trim(),
                dueDate: _selectedDate,
                priority: _selectedPriority,
                type: _selectedType,
                hasReminder: _hasReminder,
              );
              Navigator.of(context).pop(assignment);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ALUColors.primary,
            foregroundColor: ALUColors.background,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Dialog for editing existing assignments
class EditAssignmentDialog extends StatefulWidget {
  final Assignment assignment;

  const EditAssignmentDialog({super.key, required this.assignment});

  @override
  State<EditAssignmentDialog> createState() => _EditAssignmentDialogState();
}

class _EditAssignmentDialogState extends State<EditAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _courseController;
  late DateTime _selectedDate;
  late String _selectedPriority;
  late String _selectedType;
  late bool _hasReminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assignment.title);
    _descriptionController =
        TextEditingController(text: widget.assignment.description);
    _courseController = TextEditingController(text: widget.assignment.course);
    _selectedDate = widget.assignment.dueDate;
    _selectedPriority = widget.assignment.priority;
    _selectedType = widget.assignment.type;
    _hasReminder = widget.assignment.hasReminder;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Assignment'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${_selectedDate.toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items:
                    [
                      ALUConstants.lowPriority,
                      ALUConstants.mediumPriority,
                      ALUConstants.highPriority,
                    ].map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'formative',
                    child: Text('Formative'),
                  ),
                  DropdownMenuItem(
                    value: 'summative',
                    child: Text('Summative'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              CheckboxListTile(
                title: const Text('Set Reminder'),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() => _hasReminder = value ?? false);
                },
                activeColor: ALUColors.primary,
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
              final assignment = Assignment(
                id: widget.assignment.id,
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                course: _courseController.text.trim(),
                dueDate: _selectedDate,
                priority: _selectedPriority,
                type: _selectedType,
                isCompleted: widget.assignment.isCompleted,
                hasReminder: _hasReminder,
              );
              Navigator.of(context).pop(assignment);
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

