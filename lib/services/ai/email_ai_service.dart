import 'package:flutter/foundation.dart';
import '../../ai/gemma_service.dart';

class EmailAnalysis {
  final String priority;
  final String summary;
  final List<String> actions;
  EmailAnalysis(this.priority, this.summary, this.actions);
}

class EmailAiService {
  EmailAnalysis getHeuristicAnalysis(String sender, String subject, String content) {
    final lowerSubject = subject.toLowerCase();
    final lowerContent = content.toLowerCase();

    String priority = 'Medium';
    if (lowerSubject.contains('urgent') ||
        lowerSubject.contains('action required') ||
        lowerSubject.contains('important') ||
        lowerContent.contains('asap') ||
        lowerContent.contains('deadline') ||
        lowerContent.contains('today')) {
      priority = 'High';
    } else if (lowerSubject.contains('newsletter') ||
        lowerSubject.contains('digest') ||
        lowerSubject.contains('promotions') ||
        lowerSubject.contains('marketing')) {
      priority = 'Low';
    }

    final summary =
        "Email from $sender regarding '$subject'. It discusses: ${content.substring(0, content.length > 120 ? 120 : content.length)}...";

    List<String> actions;
    if (priority == 'High') {
      actions = ['Review immediately', 'Reply to sender', 'Mark on calendar'];
    } else {
      actions = ['Read email', 'Archive if not needed'];
    }

    return EmailAnalysis(priority, summary, actions);
  }

  Future<EmailAnalysis> analyzeEmailWithAI(String sender, String subject, String content) async {
    final cleanContent = content.length > 400
        ? '${content.substring(0, 400)}...'
        : content;
    final prompt = '''
Analyze this email. Return the response in a JSON-like format with exactly these tags:
[PRIORITY] (High, Medium, or Low)
[SUMMARY] (Single sentence summary)
[ACTIONS] (List of 1 to 3 action points, comma separated)

Email Sender: $sender
Subject: $subject
Content: $cleanContent
''';

    final aiResponse = await GemmaService.instance.sendMessage(prompt);
    debugPrint('[EmailAiService] AI Response: $aiResponse');

    String priority = 'Medium';
    if (aiResponse.toUpperCase().contains('[PRIORITY] HIGH')) {
      priority = 'High';
    } else if (aiResponse.toUpperCase().contains('[PRIORITY] LOW')) {
      priority = 'Low';
    }

    String summary = '';
    final summaryMatch = RegExp(
      r'\[SUMMARY\]\s*(.*)',
      caseSensitive: false,
    ).firstMatch(aiResponse);
    if (summaryMatch != null) {
      summary = summaryMatch.group(1)?.split('\n')[0].trim() ?? '';
    }
    if (summary.isEmpty) {
      summary = "AI Summary: Discusses '$subject' from $sender.";
    }

    List<String> actions = [];
    final actionsMatch = RegExp(
      r'\[ACTIONS\]\s*(.*)',
      caseSensitive: false,
    ).firstMatch(aiResponse);
    if (actionsMatch != null) {
      final rawActions = actionsMatch.group(1)?.split('\n')[0].trim() ?? '';
      actions = rawActions
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (actions.isEmpty) {
      actions = ['Review email details', 'Reply if necessary'];
    }

    return EmailAnalysis(priority, summary, actions);
  }
}
