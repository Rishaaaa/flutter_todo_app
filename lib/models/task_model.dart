class Task {
  final String? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime dueDate;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? dueDate,
  }) : dueDate = dueDate ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todo_id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dueDate.millisecondsSinceEpoch,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['todo_id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['is_completed'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['due_date']),
    );
  }
}
