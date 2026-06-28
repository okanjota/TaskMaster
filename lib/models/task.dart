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
}
