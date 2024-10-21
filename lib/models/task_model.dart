class Task {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isDeleted;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.isDeleted = false,
    DateTime? dueDate,
  }) : dueDate = dueDate ?? DateTime.now();

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isDeleted,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isDeleted: isDeleted ?? this.isDeleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
