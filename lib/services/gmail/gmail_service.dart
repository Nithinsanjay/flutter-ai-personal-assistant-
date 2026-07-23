import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import '../../models/email.dart';
import '../../models/calender_event.dart';
import '../auth/google_auth_service.dart';
import '../ai/email_ai_service.dart';
import '../calendar/calendar_service.dart';
import '../google_auth_client.dart';
import 'gmail_parser.dart';

class GmailService {
  GmailService._();
  static final GmailService instance = GmailService._();

  final GoogleAuthService _auth = GoogleAuthService();
  final EmailAiService _ai = EmailAiService();
  final CalendarService _calendar = CalendarService();

  bool get isConnected => _auth.isConnected;
  bool get isConfigured => true;
  String get userEmail => _auth.userEmail;

  Future<void> init() => _auth.init();
  Future<void> clearCredentials() => _auth.clearCredentials();
  Future<String> startOAuthFlow() => _auth.startOAuthFlow();
  Future<String?> getAccessToken() => _auth.getAccessToken();

  Future<List<EmailItem>> fetchEmails(bool aiActive) async {
    final token = await getAccessToken();
    if (token == null) {
      throw Exception('Gmail is not connected.');
    }

    final authClient = GoogleAuthClient({'Authorization': 'Bearer $token'});
    final gmailApi = gmail.GmailApi(authClient);

    final listResponse = await gmailApi.users.messages.list(
      'me',
      maxResults: 10,
    );
    final List<EmailItem> emailsList = [];

    if (listResponse.messages != null && listResponse.messages!.isNotEmpty) {
      for (var messageInfo in listResponse.messages!) {
        try {
          final msg = await gmailApi.users.messages.get('me', messageInfo.id!);
          final emailItem = await GmailParser.parseGmailMessage(msg, aiActive, _ai);
          emailsList.add(emailItem);
        } catch (e) {
          debugPrint('[GmailService] Error fetching message detail: $e');
        }
      }
    }

    return emailsList;
  }

  List<CalendarEvent> extractCalendarEvents(List<EmailItem> emails) =>
      _calendar.extractCalendarEvents(emails);

  Future<List<CalendarEvent>> fetchGoogleCalendarEvents() async {
    final token = await getAccessToken();
    if (token == null) {
      throw Exception('Gmail is not connected.');
    }
    return _calendar.fetchGoogleCalendarEvents(token);
  }
}
