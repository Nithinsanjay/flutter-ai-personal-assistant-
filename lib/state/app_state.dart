import 'dart:async';
import 'dart:convert'; // for json.decode()
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
import '../models/calender_event.dart';
import '../models/coach_message.dart';
import '../data/model_backend.dart';
import '../models/email.dart';
import '../models/task_item.dart';
import '../models/model_info.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final ModelBackend _modelBackend = ModelBackend();

  // Models
  List<ModelInfo> models = [];

  Future<void> loadModels() async {
    final data = await rootBundle.loadString('assets/models.json');
    final jsonResult = json.decode(data);
    models = (jsonResult['models'] as List)
        .map((e) => ModelInfo.fromJson(e))
        .toList();

    for (final model in models) {
      final isDownloaded = await _modelBackend.isDownloaded(model.modelFile);
      if (isDownloaded) {
        final file = await _modelBackend.getModelFile(model.modelFile);
        model.status = 'downloaded';
        model.localPath = file.path;
      }
    }

    notifyListeners();
  }

  void updateModelStatus(ModelInfo model, String newStatus) {
    model.status = newStatus;
    notifyListeners();
  }

  // Connection states
  bool _isGmailConnected = true;
  bool _isM365Connected = false;

  // Feature toggles
  bool _outlookTasksEnabled = false;
  bool _meetingPrepEnabled = false;

  // Data lists
  final List<EmailItem> _emails = [];
  final List<TaskItem> _tasks = [];
  final List<CalendarEvent> _calendarEvents = [];
  final List<CoachMessage> _coachMessages = [];

  // Active user details
  final _userName = "Pandi";

  // Getters
  bool get isGmailConnected => _isGmailConnected;
  bool get isM365Connected => _isM365Connected;
  bool get outlookTasksEnabled => _outlookTasksEnabled;
  bool get meetingPrepEnabled => _meetingPrepEnabled;
  String get userName => _userName;

  List<EmailItem> get emails => _emails.where((email) {
    if (email.source == 'Gmail' && !_isGmailConnected) return false;
    if (email.source == 'M365' && !_isM365Connected) return false;
    return true;
  }).toList();

  List<TaskItem> get tasks => _tasks;

  List<CalendarEvent> get calendarEvents => _calendarEvents.where((event) {
    if (event.source == 'Gmail' && !_isGmailConnected) return false;
    if (event.source == 'M365' && !_isM365Connected) return false;
    return true;
  }).toList();

  List<CoachMessage> get coachMessages => _coachMessages;

  // Actions
  void setGmailConnected(bool value) {
    _isGmailConnected = value;
    notifyListeners();
  }

  void setM365Connected(bool value) {
    _isM365Connected = value;
    if (!value) {
      _outlookTasksEnabled = false;
      _meetingPrepEnabled = false;
    }
    notifyListeners();
  }

  void setOutlookTasksEnabled(bool value) {
    if (_isM365Connected) {
      _outlookTasksEnabled = value;
      notifyListeners();
    }
  }

  void setMeetingPrepEnabled(bool value) {
    if (_isM365Connected) {
      _meetingPrepEnabled = value;
      notifyListeners();
    }
  }

  // (and continue with your task, email, and coach logic)

  void addManualTask(
    String title,
    String time,
    String priority,
    String status,
  ) {
    final newTask = TaskItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      time: time,
      priority: priority,
      status: status,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String status) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void createTaskFromEmail(EmailItem email) {
    // Check if task already exists from this email
    final exists = _tasks.any((t) => t.sourceEmailId == email.id);
    if (!exists) {
      final newTask = TaskItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Review: ${email.subject}",
        time: "04:00 PM",
        priority: email.priority,
        status: 'Today',
        sourceEmailId: email.id,
      );
      _tasks.add(newTask);

      // Also add calendar event
      _calendarEvents.add(
        CalendarEvent(
          id: "cal_${newTask.id}",
          title: "Review: ${email.subject}",
          startTime: "16:00",
          endTime: "16:30",
          type: 'Task',
          source: email.source,
        ),
      );

      notifyListeners();
    }
  }

  void addCoachMessage(String text, bool isUser) {
    _coachMessages.add(
      CoachMessage(text: text, isUser: isUser, timestamp: DateTime.now()),
    );
    notifyListeners();

    if (isUser) {
      // Simulate AI response
      Future.delayed(const Duration(milliseconds: 800), () {
        String response = _generateAIResponse(text);
        _coachMessages.add(
          CoachMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        notifyListeners();
      });
    }
  }

  String _generateAIResponse(String prompt) {
    final cleanPrompt = prompt.toLowerCase();
    if (cleanPrompt.contains('what should i do') ||
        cleanPrompt.contains('priorities')) {
      final highTasks = _tasks
          .where((t) => t.priority == 'High' && t.status != 'Completed')
          .toList();
      if (highTasks.isNotEmpty) {
        return "You have ${highTasks.length} high priority tasks remaining. I suggest starting with '${highTasks.first.title}' scheduled at ${highTasks.first.time}.";
      }
      return "All high priority tasks are completed! You can review your medium priority tasks or check the calendar for next meetings.";
    } else if (cleanPrompt.contains('email')) {
      final unreadCount = emails.length;
      return "You have $unreadCount active emails synced from your connections. Gmail shows ${_emails.where((e) => e.source == 'Gmail').length} items, and Microsoft 365 shows ${_emails.where((e) => e.source == 'M365').length} items.";
    } else if (cleanPrompt.contains('task')) {
      final total = _tasks.length;
      final completed = _tasks.where((t) => t.status == 'Completed').length;
      return "Currently, you've completed $completed out of $total tasks today. Keep going!";
    } else if (cleanPrompt.contains('meeting') ||
        cleanPrompt.contains('calendar')) {
      final events = calendarEvents;
      if (events.isNotEmpty) {
        return "Your next event is '${events.first.title}' starting shortly. Check your Unified Calendar for the full list.";
      }
      return "No calendar events scheduled for today. You have a clear slot!";
    } else {
      return "I've analyzed your synced emails and calendar. Let me know if you want me to summarize emails, list pending tasks, or help reschedule meetings.";
    }
  }

  Future<void> startDownload(ModelInfo model) async {
    print("START DOWNLOAD");
    print("URL: ${model.downloadUrl}");
    print("FILE: ${model.modelFile}");

    model.status = 'downloading';
    model.progress = 0.0;
    model.errorMessage = null;
    notifyListeners();

    try {
      print("MODEL NAME = ${model.name}");
      print("MODEL ID = ${model.modelId}");
      print("COMMIT HASH = ${model.commitHash}");
      print("MODEL FILE = ${model.modelFile}");
      print("DOWNLOAD URL = ${model.downloadUrl}");
      print("BUILD URL = ${model.buildDownloadUrl()}");

      await _modelBackend.downloadModel(
        model.name,
        model.modelFile,
        model.buildDownloadUrl(),
        onProgress: (progress) {
          model.progress = progress.clamp(0.0, 1.0).toDouble();
          notifyListeners();
        },
      );

      final file = await _modelBackend.getModelFile(model.modelFile);
      print("FILE PATH = ${file.path}");
      print("FILE EXISTS = ${await file.exists()}");
      print("FILE SIZE = ${await file.length()}");
      model.status = 'downloaded';
      model.progress = 0.0;
      model.localPath = file.path;
      notifyListeners();
    } catch (error) {
      model.status = 'download';
      model.progress = 0.0;
      model.errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> connectModel(ModelInfo model) async {
    model.status = 'connecting';
    model.errorMessage = null;
    notifyListeners();

    try {
      model.localPath = await _modelBackend.initializeModel(
        model.name,
        model.modelFile,
      );
      model.status = 'connected';
      notifyListeners();
    } catch (error) {
      model.status = 'downloaded';
      model.errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> disconnectModel(ModelInfo model) async {
    await _modelBackend.disconnectModel();
    model.status = 'downloaded';
    model.errorMessage = null;
    notifyListeners();
  }

  Future<void> deleteModel(ModelInfo model) async {
    try {
      await _modelBackend.deleteModel(model.modelFile);
      model.status = 'download';
      model.progress = 0.0;
      model.localPath = null;
      model.errorMessage = null;
      notifyListeners();
    } catch (error) {
      model.errorMessage = error.toString();
      notifyListeners();
    }
  }
}

// class AppStateProvider extends InheritedNotifier<AppState> {
//   const AppStateProvider({
//     super.key,
//     required super.notifier,
//     required super.child,
//   });

//   static AppState of(BuildContext context) {
//     return context
//         .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
//         .notifier!;
//   }
// }
