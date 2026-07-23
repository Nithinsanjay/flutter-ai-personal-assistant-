import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import '../../models/email.dart';
import '../../models/calender_event.dart';
import '../google_auth_client.dart';

class CalendarService {
  /// Extract meetings/sessions from a list of email messages (generic, works for both Gmail/Outlook)
  List<CalendarEvent> extractCalendarEvents(List<EmailItem> emails) {
    final List<CalendarEvent> events = [];
    for (var email in emails) {
      final lowerSubject = email.subject.toLowerCase();
      final lowerContent = email.content.toLowerCase();

      if (lowerSubject.contains('meeting') ||
          lowerSubject.contains('appointment') ||
          lowerSubject.contains('session') ||
          lowerSubject.contains('calendar') ||
          lowerSubject.contains('schedule') ||
          lowerContent.contains('zoom link') ||
          lowerContent.contains('google meet')) {
        String startTime = '11:00';
        String endTime = '11:30';

        final timeRegex = RegExp(
          r'(\d{1,2}):(\d{2})\s*(AM|PM)',
          caseSensitive: false,
        );
        final match = timeRegex.firstMatch(email.content);
        if (match != null) {
          int hour = int.parse(match.group(1)!);
          final minute = match.group(2)!;
          final ampm = match.group(3)!.toUpperCase();
          if (ampm == 'PM' && hour < 12) hour += 12;
          if (ampm == 'AM' && hour == 12) hour = 0;
          startTime = '${hour.toString().padLeft(2, '0')}:$minute';
          final endMin = (int.parse(minute) + 30) % 60;
          final endHour = (hour + (int.parse(minute) + 30 ~/ 60)) % 24;
          endTime =
              '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
        }

        events.add(
          CalendarEvent(
            id: 'gmail_cal_${email.id}',
            title: email.subject.length > 30
                ? '${email.subject.substring(0, 30)}...'
                : email.subject,
            startTime: startTime,
            endTime: endTime,
            type: 'Meeting',
            source: email.source,
            date: email.date,
          ),
        );
      }
    }
    return events;
  }

  /// Fetches Google Calendar events using a Google API access token
  Future<List<CalendarEvent>> fetchGoogleCalendarEvents(String token) async {
    final authClient = GoogleAuthClient({'Authorization': 'Bearer $token'});
    final calendarApi = calendar.CalendarApi(authClient);

    final now = DateTime.now();
    final timeMin = now.subtract(const Duration(days: 7));
    final timeMax = now.add(const Duration(days: 30));

    final eventsResponse = await calendarApi.events.list(
      'primary',
      timeMin: timeMin.toUtc(),
      timeMax: timeMax.toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    final List<CalendarEvent> calEvents = [];
    if (eventsResponse.items != null) {
      for (var item in eventsResponse.items!) {
        if (item.status == 'cancelled') continue;

        final startDateTime = item.start?.dateTime ?? item.start?.date;
        final endDateTime = item.end?.dateTime ?? item.end?.date;
        if (startDateTime == null || endDateTime == null) continue;

        final parsedStart = startDateTime.toLocal();
        final parsedEnd = endDateTime.toLocal();

        final dateStr = DateFormat('yyyy-MM-dd').format(parsedStart);
        final startTimeStr = DateFormat('HH:mm').format(parsedStart);
        final endTimeStr = DateFormat('HH:mm').format(parsedEnd);

        String type = 'Meeting';
        final summaryLower = (item.summary ?? '').toLowerCase();
        final descLower = (item.description ?? '').toLowerCase();
        
        if (summaryLower.contains('focus') || summaryLower.contains('deep work') || descLower.contains('focus')) {
          type = 'Focus';
        } else if (summaryLower.contains('task') || summaryLower.contains('todo') || descLower.contains('task')) {
          type = 'Task';
        } else if (summaryLower.contains('personal') || summaryLower.contains('private') || descLower.contains('personal')) {
          type = 'Personal';
        }

        debugPrint('[CalendarService] Fetched Google Calendar event: ${item.summary}, start: $startDateTime, type: $type, date: $dateStr, time: $startTimeStr-$endTimeStr');

        calEvents.add(
          CalendarEvent(
            id: item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: item.summary ?? 'No Title',
            startTime: startTimeStr,
            endTime: endTimeStr,
            type: type,
            source: 'Gmail',
            date: dateStr,
          ),
        );
      }
    }
    return calEvents;
  }
}
