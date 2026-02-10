/// Session model representing an academic session with attendance tracking
class Session {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String type;
  final bool attended;

  Session({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.attended = false,
  });

  /// Create a Session from JSON data
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      type: json['type'] as String,
      attended: json['attended'] as bool? ?? false,
    );
  }

  /// Convert Session to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'attended': attended,
    };
  }

  /// Create a copy of Session with optional new values
  Session copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? type,
    bool? attended,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      attended: attended ?? this.attended,
    );
  }

  @override
  String toString() {
    return 'Session(id: $id, title: $title, date: $date, type: $type, attended: $attended)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Session &&
        other.id == id &&
        other.title == title &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.type == type &&
        other.attended == attended;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        date.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        type.hashCode ^
        attended.hashCode;
  }
}
