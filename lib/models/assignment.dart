/// Assignment model representing a task with due date and priority
class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final String type; // 'summative', 'formative', etc.
  final bool isCompleted;
  final bool hasReminder;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.type,
    this.isCompleted = false,
    this.hasReminder = false,
  });

  /// Create an Assignment from JSON data
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: json['priority'] as String,
      type: json['type'] as String? ?? 'formative',
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasReminder: json['hasReminder'] as bool? ?? false,
    );
  }

  /// Convert Assignment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'hasReminder': hasReminder,
    };
  }

  /// Create a copy of Assignment with optional new values
  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    String? type,
    bool? isCompleted,
    bool? hasReminder,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
    );
  }

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, dueDate: $dueDate, priority: $priority, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Assignment &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.isCompleted == isCompleted &&
        other.hasReminder == hasReminder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        dueDate.hashCode ^
        priority.hashCode ^
        isCompleted.hashCode ^
        hasReminder.hashCode;
  }
}
