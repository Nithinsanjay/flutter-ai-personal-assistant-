import 'dart:async';
import 'dart:convert'; // for json.decode()
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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
  });
}

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

class CoachMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  CoachMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// new entry starts -->

class ModelInfo {
  final String name;
  final double sizeGB;
  final String description;
  final String modelFile;
  final String commitHash;
  final List<String> accelerators;
  final bool updateAvailable;
  final bool bestOverall;
  String status;
  double progress; //

  ModelInfo({
    required this.name,
    required this.sizeGB,
    required this.description,
    required this.modelFile,
    required this.commitHash,
    required this.accelerators,
    required this.updateAvailable,
    required this.bestOverall,
    this.status = 'download',
    this.progress = 0.0,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) => ModelInfo(
    name: json['name'],
    sizeGB: json['sizeGB'].toDouble(),
    description: json['description'],
    modelFile: json['modelFile'],
    commitHash: json['commitHash'],
    accelerators: List<String>.from(json['accelerators']),
    updateAvailable: json['updateAvailable'],
    bestOverall: json['bestOverall'],
  );
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Models
  List<ModelInfo> models = [];

  Future<void> loadModels() async {
    final data = await rootBundle.loadString('assets/models.json');
    final jsonResult = json.decode(data);
    models = (jsonResult['models'] as List)
        .map((e) => ModelInfo.fromJson(e))
        .toList();
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
  List<EmailItem> _emails = [];
  List<TaskItem> _tasks = [];
  List<CalendarEvent> _calendarEvents = [];
  List<CoachMessage> _coachMessages = [];

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

  void _loadInitialData() {
    // 1. Initial Emails
    _emails = [
      EmailItem(
        id: "gmail_1",
        sender: "Paul Smith",
        subject: "Proposal Approval Needed",
        snippet: "Hi Pandi, please review the proposal doc and approve...",
        time: "08:15 AM",
        priority: "High",
        source: "Gmail",
        content:
            "Paul is requesting you to review the proposal document and provide approval by EOD. This is critical for the client sign-off.",
        suggestedActions: [
          "Review the proposal document",
          "Provide feedback",
          "Approve and send confirmation",
        ],
        aiSummary:
            "Paul is requesting you to review the proposal document and provide approval by EOD.",
      ),
      EmailItem(
        id: "gmail_2",
        sender: "HR - Internship",
        subject: "Intern Onboarding Plan",
        snippet: "Please find the onboarding plan for the new interns...",
        time: "08:33 AM",
        priority: "Medium",
        source: "Gmail",
        content:
            "Please find the onboarding plan for the new interns starting next Monday. We need your confirmation on the schedule.",
        suggestedActions: [
          "Confirm onboarding schedule",
          "Assign mentors for interns",
        ],
        aiSummary:
            "The HR department needs confirmation on the onboarding schedule for the new interns starting next week.",
      ),
      EmailItem(
        id: "gmail_3",
        sender: "Newsletter",
        subject: "Weekly Tech News",
        snippet: "Your weekly dose of technology and innovation...",
        time: "Yesterday",
        priority: "Low",
        source: "Gmail",
        content:
            "This week's roundup on local AI frameworks, on-device model training, and trends in flutter development.",
        suggestedActions: ["Read article about on-device AI"],
        aiSummary:
            "Weekly technology newsletter with topics on local AI and Flutter development.",
      ),
      // M365 Emails (Available when connected)
      EmailItem(
        id: "m365_1",
        sender: "Naxent Team",
        subject: "Deployment Completed",
        snippet: "The production deployment is completed successfully...",
        time: "09:45 AM",
        priority: "High",
        source: "M365",
        content:
            "The production deployment has been completed successfully. All automated sanity checks are passing.",
        suggestedActions: ["Review deployment logs", "Notify stakeholders"],
        aiSummary:
            "The Naxent production deployment has been completed successfully and passed sanity checks.",
      ),
      EmailItem(
        id: "m365_2",
        sender: "Secure Pickup",
        subject: "Flow Review Request",
        snippet: "Requesting review and feedback on the new flow...",
        time: "07:50 AM",
        priority: "Medium",
        source: "M365",
        content:
            "We have finalized the secure checkout pickup flow. Please review and provide your sign-off.",
        suggestedActions: ["Review checkout flow document", "Provide feedback"],
        aiSummary:
            "Secure Pickup team is requesting a review and feedback on the new checkout pickup flow.",
      ),
    ];

    // 2. Initial Tasks
    _tasks = [
      TaskItem(
        id: "task_1",
        title: "Reply to Paul about the proposal",
        time: "10:00 AM",
        priority: "High",
        status: "Today",
        sourceEmailId: "gmail_1",
      ),
      TaskItem(
        id: "task_2",
        title: "Review GTM Production Setup",
        time: "11:30 AM",
        priority: "High",
        status: "Today",
      ),
      TaskItem(
        id: "task_3",
        title: "Internship Onboarding Review",
        time: "02:00 PM",
        priority: "Medium",
        status: "Today",
        sourceEmailId: "gmail_2",
      ),
      TaskItem(
        id: "task_4",
        title: "Gold EMI Flow Validation",
        time: "03:30 PM",
        priority: "Medium",
        status: "Today",
      ),
      TaskItem(
        id: "task_5",
        title: "Secure Pickup Review",
        time: "01:00 PM",
        priority: "Medium",
        status: "InProgress",
        sourceEmailId: "m365_2",
      ),
      TaskItem(
        id: "task_6",
        title: "Smoke Test Validation",
        time: "04:30 PM",
        priority: "Medium",
        status: "InProgress",
      ),
      TaskItem(
        id: "task_7",
        title: "Deployment Smoke Test",
        time: "Yesterday",
        priority: "Medium",
        status: "Completed",
        sourceEmailId: "m365_1",
      ),
    ];

    // 3. Initial Calendar Events
    _calendarEvents = [
      CalendarEvent(
        id: "cal_1",
        title: "Team Standup",
        startTime: "09:00",
        endTime: "09:30",
        type: "Meeting",
        source: "Gmail",
      ),
      CalendarEvent(
        id: "cal_2",
        title: "Reply to Paul",
        startTime: "10:00",
        endTime: "10:30",
        type: "Task",
        source: "Gmail",
      ),
      CalendarEvent(
        id: "cal_3",
        title: "Review GTM Setup",
        startTime: "11:30",
        endTime: "12:30",
        type: "Meeting",
        source: "Gmail",
      ),
      CalendarEvent(
        id: "cal_4",
        title: "Lunch Break",
        startTime: "13:00",
        endTime: "13:30",
        type: "Personal",
        source: "Local",
      ),
      CalendarEvent(
        id: "cal_5",
        title: "Focus Block",
        startTime: "14:00",
        endTime: "16:00",
        type: "Focus",
        source: "Local",
      ),
      CalendarEvent(
        id: "cal_6",
        title: "Internship Onboarding",
        startTime: "16:00",
        endTime: "17:00",
        type: "Meeting",
        source: "Gmail",
      ),
      // M365 Synced events (Available when M365 connected)
      CalendarEvent(
        id: "cal_7",
        title: "Naxent Post-Mortem",
        startTime: "11:00",
        endTime: "11:30",
        type: "Meeting",
        source: "M365",
      ),
      CalendarEvent(
        id: "cal_8",
        title: "Secure Pickup Review",
        startTime: "13:30",
        endTime: "14:00",
        type: "Meeting",
        source: "M365",
      ),
    ];

    // 4. AI Coach messages
    _coachMessages = [
      CoachMessage(
        text:
            "Great job, Pandi! You have completed 1 of 7 tasks today. Your productivity score is 60%.",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      CoachMessage(
        text:
            "Recommended Next Task:\nReview GTM Production Setup. This is a high priority task due in 45 mins.",
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
  }
  // --- Model lifecycle actions ---

  // Start download with progress simulation
  void startDownload(ModelInfo model) async {
    model.status = 'downloading';
    notifyListeners();

    // Simulate download progress (increments every 300ms)
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      model.progress = i / 10;
      notifyListeners();
    }

    // Once download completes, show connect/delete
    model.status = 'downloaded';
    model.progress = 0.0;
    notifyListeners();
  }

  // Connect model
  void connectModel(ModelInfo model) async {
    model.status = 'connecting';
    notifyListeners();

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));
    model.status = 'connected';
    notifyListeners();
  }

  // Disconnect model
  void disconnectModel(ModelInfo model) {
    model.status = 'downloaded'; // back to downloaded state
    notifyListeners();
  }

  // Delete model (reset to initial state)
  void deleteModel(ModelInfo model) {
    model.status = 'download'; // back to initial state
    model.progress = 0.0;
    notifyListeners();
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    Key? key,
    required AppState notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }
}
