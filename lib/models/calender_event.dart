class CalendarEvent {
  final String id;
  final String title;
  final String startTime;
  final String endTime;
  final String type; // 'Meeting', 'Task', 'Focus', 'Personal'
  final String source; // 'Gmail', 'M365', 'Local'

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.source,
  });
}
