/// User model representing a student profile
class User {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String program;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.program,
  });

  /// Create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      studentId: json['studentId'] as String,
      program: json['program'] as String,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentId': studentId,
      'program': program,
    };
  }

  /// Create a copy of User with optional new values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? program,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      program: program ?? this.program,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, studentId: $studentId, program: $program)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.studentId == studentId &&
        other.program == program;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        studentId.hashCode ^
        program.hashCode;
  }
}
