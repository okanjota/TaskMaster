enum Priority { baixa, media, alta }

class Task {
  final String id;
  String title;
  String description;
  Priority priority;
  String category;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.dueDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.name,
        'category': category,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        priority: Priority.values.byName(json['priority'] as String),
        category: json['category'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        isCompleted: json['isCompleted'] as bool,
      );
}
