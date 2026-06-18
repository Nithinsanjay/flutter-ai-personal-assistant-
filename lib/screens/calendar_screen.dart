import 'package:flutter/material.dart';
import '../state/app_state.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDayIndex = 0; // Monday 15th

  final List<Map<String, String>> _daysOfWeek = [
    {'day': 'M', 'date': '15'},
    {'day': 'T', 'date': '16'},
    {'day': 'W', 'date': '17'},
    {'day': 'T', 'date': '18'},
    {'day': 'F', 'date': '19'},
    {'day': 'S', 'date': '20'},
    {'day': 'S', 'date': '21'},
  ];

  final List<String> _hours = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final events = state.calendarEvents;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'June 2026',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _daysOfWeek.length,
                itemBuilder: (context, index) {
                  final day = _daysOfWeek[index];
                  final isSelected = index == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Container(
                      width: 44,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF818CF8)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4F46E5,
                                  ).withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day['day']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day['date']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.calendar_month, color: Color(0xFF64748B), size: 14),
                SizedBox(width: 6),
                Text(
                  'TODAY\'S AGENDA',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hours.length,
              itemBuilder: (context, index) {
                final hourStr = _hours[index];
                final hourNum = index + 9;

                final slotEvents = events.where((e) {
                  final startHour = int.parse(e.startTime.split(':')[0]);
                  return startHour == hourNum;
                }).toList();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        hourStr,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 16, bottom: 20),
                        child: slotEvents.isEmpty
                            ? const SizedBox(height: 40)
                            : Column(
                                children: slotEvents
                                    .map((e) => _buildEventCard(e))
                                    .toList(),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Scheduling meetings requires Microsoft 365 or Google connection.',
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    Color borderAccent;
    IconData icon;

    switch (event.type) {
      case 'Meeting':
        borderAccent = Colors.blue;
        icon = Icons.people_outline;
        break;
      case 'Task':
        borderAccent = const Color(0xFF818CF8);
        icon = Icons.task_alt_outlined;
        break;
      case 'Focus':
        borderAccent = Colors.green;
        icon = Icons.alarm_on_outlined;
        break;
      case 'Personal':
      default:
        borderAccent = Colors.amber;
        icon = Icons.sentiment_satisfied_alt_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: borderAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF64748B), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${event.startTime} - ${event.endTime}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.source,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
