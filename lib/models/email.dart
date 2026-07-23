class EmailItem {
  final String id;
  final String sender;
  final String subject;
  final String snippet;
  final String time;
  final String priority; // 'High', 'Medium', 'Low'
  final String source; // 'Gmail', 'M365'
  final String content;
  final List<String> suggestedActions;
  final String aiSummary;
  final String date; // 'yyyy-MM-dd'

  EmailItem({
    required this.id,
    required this.sender,
    required this.subject,
    required this.snippet,
    required this.time,
    required this.priority,
    required this.source,
    required this.content,
    required this.suggestedActions,
    required this.aiSummary,
    required this.date,
  });
}
