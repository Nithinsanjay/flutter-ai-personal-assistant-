import 'package:flutter/foundation.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:intl/intl.dart';
import '../../models/email.dart';
import '../../ai/gemma_service.dart';
import '../ai/email_ai_service.dart';
import '../utils/gmail_utils.dart';

class GmailParser {
  static Future<EmailItem> parseGmailMessage(
    gmail.Message msg,
    bool aiActive,
    EmailAiService aiService,
  ) async {
    final headers = msg.payload?.headers;
    String sender = 'Unknown Sender';
    String subject = '(No Subject)';
    String dateStr = '';

    if (headers != null) {
      for (var header in headers) {
        final name = header.name?.toLowerCase();
        if (name == 'from') {
          sender = header.value ?? sender;
        } else if (name == 'subject') {
          subject = header.value ?? subject;
        } else if (name == 'date') {
          dateStr = header.value ?? dateStr;
        }
      }
    }

    sender = sender.replaceAll('"', '');

    String timeDisplay = '09:00 AM';
    String parsedDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    try {
      if (dateStr.isNotEmpty) {
        final parsedDate =
            DateTime.tryParse(dateStr) ?? GmailUtils.parseHttpDate(dateStr);
        if (parsedDate != null) {
          parsedDateStr = DateFormat('yyyy-MM-dd').format(parsedDate);
          final now = DateTime.now();
          if (parsedDate.year == now.year &&
              parsedDate.month == now.month &&
              parsedDate.day == now.day) {
            final hour = parsedDate.hour > 12
                ? parsedDate.hour - 12
                : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
            final minute = parsedDate.minute.toString().padLeft(2, '0');
            final ampm = parsedDate.hour >= 12 ? 'PM' : 'AM';
            timeDisplay = '$hour:$minute $ampm';
          } else {
            final monthNames = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            timeDisplay =
                '${monthNames[parsedDate.month - 1]} ${parsedDate.day}';
          }
        }
      }
    } catch (_) {}

    final snippet = msg.snippet ?? '';
    String content = snippet;
    if (msg.payload != null) {
      final bodyText = _parseBody(msg.payload!);
      if (bodyText.isNotEmpty) {
        content = bodyText;
      }
    }

    content = GmailUtils.cleanHtmlTags(content);

    String priority = 'Medium';
    String aiSummary = '';
    List<String> suggestedActions = [];

    if (aiActive && GemmaService.instance.isInitialized) {
      try {
        final analysis = await aiService.analyzeEmailWithAI(sender, subject, content);
        priority = analysis.priority;
        aiSummary = analysis.summary;
        suggestedActions = analysis.actions;
      } catch (e) {
        debugPrint('[GmailParser] AI processing failed, using fallback: $e');
        final fallback = aiService.getHeuristicAnalysis(sender, subject, content);
        priority = fallback.priority;
        aiSummary = fallback.summary;
        suggestedActions = fallback.actions;
      }
    } else {
      final fallback = aiService.getHeuristicAnalysis(sender, subject, content);
      priority = fallback.priority;
      aiSummary = fallback.summary;
      suggestedActions = fallback.actions;
    }

    return EmailItem(
      id: msg.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: sender,
      subject: subject,
      snippet: snippet.length > 80 ? '${snippet.substring(0, 80)}...' : snippet,
      time: timeDisplay,
      priority: priority,
      source: 'Gmail',
      content: content,
      suggestedActions: suggestedActions,
      aiSummary: aiSummary,
      date: parsedDateStr,
    );
  }

  static String _parseBody(gmail.MessagePart part) {
    if (part.mimeType == 'text/plain' && part.body?.data != null) {
      return GmailUtils.decodeBase64(part.body!.data!);
    }
    if (part.mimeType == 'text/html' && part.body?.data != null) {
      return GmailUtils.decodeBase64(part.body!.data!);
    }

    if (part.parts != null) {
      for (var subPart in part.parts!) {
        final body = _parseBody(subPart);
        if (body.isNotEmpty) return body;
      }
    }
    return '';
  }
}
