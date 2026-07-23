import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/coach_message.dart';
import '../models/model_info.dart';
import '../models/task_item.dart';
import '../models/email.dart';
import '../models/calender_event.dart';
import '../ai/chat_service.dart';

class CoachViewModel extends ChangeNotifier {
  final List<CoachMessage> coachMessages = [];
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;
  StreamSubscription<String>? _streamSubscription;

  void addMessage(CoachMessage message) {
    coachMessages.add(message);
    notifyListeners();
  }

  void updateLastMessage(String text) {
    if (coachMessages.isEmpty) return;
    final last = coachMessages.last;
    coachMessages[coachMessages.length - 1] = CoachMessage(
      text: text,
      isUser: last.isUser,
      timestamp: last.timestamp,
    );
    notifyListeners();
  }

  void sendCoachMessage({
    required String prompt,
    required ModelInfo? connectedModel,
    required List<TaskItem> tasks,
    required List<EmailItem> filteredEmails,
    required List<EmailItem> rawEmails,
    required List<CalendarEvent> calendarEvents,
  }) {
    if (prompt.trim().isEmpty || _isGenerating) return;

    final text = prompt.trim();
    _isGenerating = true;
    notifyListeners();

    // Add user message
    addMessage(
      CoachMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );

    // If no model is connected, generate a fallback response
    if (connectedModel == null) {
      addMessage(
        CoachMessage(
          text: "🤖 Thinking...",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 800), () {
        final fallbackResponse = generateAIResponse(
          prompt: text,
          connectedModel: null,
          tasks: tasks,
          filteredEmails: filteredEmails,
          rawEmails: rawEmails,
          calendarEvents: calendarEvents,
        );

        updateLastMessage(fallbackResponse);
        _isGenerating = false;
        notifyListeners();
      });
      return;
    }

    // Otherwise, stream response from model
    try {
      addMessage(
        CoachMessage(
          text: "🤖 Thinking...",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();

      String streamedResponse = "";
      bool firstChunk = true;

      _streamSubscription = ChatService.sendMessageStream(text).listen(
        (chunk) {
          if (firstChunk) {
            streamedResponse = "";
            firstChunk = false;
          }
          streamedResponse += chunk;
          updateLastMessage(streamedResponse);
        },
        onDone: () {
          _isGenerating = false;
          notifyListeners();
        },
        onError: (e) {
          updateLastMessage('Error: $e');
          _isGenerating = false;
          notifyListeners();
        },
      );
    } catch (e) {
      updateLastMessage('Error: $e');
      _isGenerating = false;
      notifyListeners();
    }
  }

  void stopCoachGeneration() {
    _streamSubscription?.cancel();
    _isGenerating = false;
    notifyListeners();
  }

  String generateAIResponse({
    required String prompt,
    required ModelInfo? connectedModel,
    required List<TaskItem> tasks,
    required List<EmailItem> filteredEmails,
    required List<EmailItem> rawEmails,
    required List<CalendarEvent> calendarEvents,
  }) {
    final modelName = connectedModel?.name ?? "On-Device AI";
    String responseBody;
    final cleanPrompt = prompt.toLowerCase();

    if (cleanPrompt.contains('what should i do') ||
        cleanPrompt.contains('priorities')) {
      final highTasks = tasks
          .where((t) => t.priority == 'High' && t.status != 'Completed')
          .toList();
      if (highTasks.isNotEmpty) {
        responseBody =
            "You have ${highTasks.length} high priority tasks remaining. I suggest starting with '${highTasks.first.title}' scheduled at ${highTasks.first.time}.";
      } else {
        responseBody =
            "All high priority tasks are completed! You can review your medium priority tasks or check the calendar for next meetings.";
      }
    } else if (cleanPrompt.contains('email')) {
      responseBody =
          "You have ${filteredEmails.length} active emails synced from your connections. Gmail shows ${rawEmails.where((e) => e.source == 'Gmail').length} items, and Microsoft 365 shows ${rawEmails.where((e) => e.source == 'M365').length} items.";
    } else if (cleanPrompt.contains('task')) {
      final completed = tasks.where((t) => t.status == 'Completed').length;
      responseBody =
          "Currently, you've completed $completed out of ${tasks.length} tasks today. Keep going!";
    } else if (cleanPrompt.contains('meeting') ||
        cleanPrompt.contains('calendar')) {
      if (calendarEvents.isNotEmpty) {
        responseBody =
            "Your next event is '${calendarEvents.first.title}' starting shortly. Check your Unified Calendar for the full list.";
      } else {
        responseBody =
            "No calendar events scheduled for today. You have a clear slot!";
      }
    } else {
      responseBody =
          "I've analyzed your synced emails and calendar. Let me know if you want me to summarize emails, list pending tasks, or help reschedule meetings.";
    }
    return "[$modelName]: $responseBody";
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
