import 'package:flutter/foundation.dart';
import '../models/email.dart';
import '../models/task_item.dart';
import '../models/calender_event.dart';
import '../services/gmail/gmail_service.dart';

class WorkflowViewModel extends ChangeNotifier {
  final List<EmailItem> rawEmails = [];
  final List<TaskItem> tasks = [];
  final List<CalendarEvent> rawCalendarEvents = [];

  bool _isGmailSyncing = false;
  bool get isGmailSyncing => _isGmailSyncing;

  List<EmailItem> getFilteredEmails({
    required bool gmailConnected,
    required bool m365Connected,
  }) {
    return rawEmails.where((email) {
      if (email.source == 'Gmail' && !gmailConnected) return false;
      if (email.source == 'M365' && !m365Connected) return false;
      return true;
    }).toList();
  }

  List<CalendarEvent> getFilteredCalendar({
    required bool gmailConnected,
    required bool m365Connected,
  }) {
    return rawCalendarEvents.where((event) {
      if (event.source == 'Gmail' && !gmailConnected) return false;
      if (event.source == 'M365' && !m365Connected) return false;
      return true;
    }).toList();
  }

  void addManualTask(
    String title,
    String time,
    String priority,
    String status,
  ) {
    tasks.add(
      TaskItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        time: time,
        priority: priority,
        status: status,
        dueDate: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String status) {
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      tasks[index] = tasks[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void createTaskFromEmail(EmailItem email) {
    final exists = tasks.any((t) => t.sourceEmailId == email.id);
    if (!exists) {
      final newTaskId = DateTime.now().millisecondsSinceEpoch.toString();
      tasks.add(
        TaskItem(
          id: newTaskId,
          title: "Review: ${email.subject}",
          time: "04:00 PM",
          priority: email.priority,
          status: 'Pending',
          dueDate: DateTime.now(),
          sourceEmailId: email.id,
        ),
      );

      rawCalendarEvents.add(
        CalendarEvent(
          id: "cal_$newTaskId",
          title: "Review: ${email.subject}",
          startTime: "16:00",
          endTime: "16:30",
          type: 'Task',
          source: email.source,
          date: email.date,
        ),
      );
      notifyListeners();
    }
  }

  void clearGmailData() {
    final gmailCalTaskIds = rawCalendarEvents
        .where((e) => e.source == 'Gmail' && e.type == 'Task')
        .map((e) => e.id)
        .toSet();

    rawEmails.removeWhere((email) => email.source == 'Gmail');
    rawCalendarEvents.removeWhere((event) => event.source == 'Gmail');
    tasks.removeWhere((t) => gmailCalTaskIds.contains(t.id) && t.sourceEmailId == null);
    notifyListeners();
  }

  void setGmailEmails(List<EmailItem> emails) {
    rawEmails.removeWhere((email) => email.source == 'Gmail');
    rawEmails.addAll(emails);
    notifyListeners();
  }

  void setGmailCalendarEvents(List<CalendarEvent> events) {
    rawCalendarEvents.removeWhere((event) => event.source == 'Gmail');
    rawCalendarEvents.addAll(events);

    // Sync tasks from calendar events of type 'Task'
    for (var event in events) {
      if (event.type == 'Task' && !event.id.startsWith('cal_')) {
        final exists = tasks.any((t) => t.id == event.id);
        if (!exists) {
          final parsedDate = DateTime.tryParse(event.date) ?? DateTime.now();
          tasks.add(
            TaskItem(
              id: event.id,
              title: event.title,
              time: event.startTime,
              priority: 'Medium',
              status: 'Pending',
              dueDate: parsedDate,
              sourceEmailId: null,
            ),
          );
        }
      }
    }
    notifyListeners();
  }

  Future<void> syncGmail({
    required bool gmailConnected,
    required bool aiActive,
  }) async {
    if (!gmailConnected) return;

    _isGmailSyncing = true;
    notifyListeners();

    try {
      await GmailService.instance.init();
      final emailsList = await GmailService.instance.fetchEmails(aiActive);

      setGmailEmails(emailsList);

      final calEvents = GmailService.instance.extractCalendarEvents(emailsList);
      try {
        final googleCalendarEvents = await GmailService.instance
            .fetchGoogleCalendarEvents();
        calEvents.addAll(googleCalendarEvents);
      } catch (calErr) {
        debugPrint(
          '[WorkflowViewModel] Error fetching Google Calendar events: $calErr',
        );
      }
      setGmailCalendarEvents(calEvents);
    } catch (e) {
      debugPrint('[WorkflowViewModel] Gmail sync error: $e');
      rethrow;
    } finally {
      _isGmailSyncing = false;
      notifyListeners();
    }
  }
}
