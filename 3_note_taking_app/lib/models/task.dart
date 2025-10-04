class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  // Convert Task to Map for Sembast
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Task from Map (Sembast record)
  factory Task.fromMap(Map<String, dynamic> map, int id) {
    return Task(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Copy with method for updates
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
