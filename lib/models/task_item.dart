class TaskItem {
  final String id;
  final String title;
  final String time;
  final String priority; // 'High', 'Medium', 'Low'
  final String status; // 'Today', 'InProgress', 'Completed'
  final String? sourceEmailId;

  TaskItem({
    required this.id,
    required this.title,
    required this.time,
    required this.priority,
    required this.status,
    this.sourceEmailId,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? time,
    String? priority,
    String? status,
    String? sourceEmailId,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      sourceEmailId: sourceEmailId ?? this.sourceEmailId,
    );
  }
}
