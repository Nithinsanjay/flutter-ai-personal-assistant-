class TaskItem {
  final String id;
  final String title;
  final String time;
  final String priority; // 'High', 'Medium', 'Low'
  final String status; // 'Pending(Today)', 'InProgress', 'Completed'
  final DateTime dueDate;
  final String? sourceEmailId;

  TaskItem({
    required this.id,
    required this.title,
    required this.time,
    required this.priority,
    required this.status,
    required this.dueDate,
    this.sourceEmailId,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? time,
    String? priority,
    String? status,
    DateTime? dueDate,
    String? sourceEmailId,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      sourceEmailId: sourceEmailId ?? this.sourceEmailId,
    );
  }
}
