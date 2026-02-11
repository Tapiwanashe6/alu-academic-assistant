/// Announcement model representing university announcements
class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String priority;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.priority,
  });

  /// Create an Announcement from JSON data
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      priority: json['priority'] as String,
    );
  }

  /// Convert Announcement to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'priority': priority,
    };
  }

  /// Create a copy of Announcement with optional new values
  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? priority,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, date: $date, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.date == date &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        date.hashCode ^
        priority.hashCode;
  }
}
