import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/connectivity_viewmodel.dart';
import '../viewmodels/workflow_viewmodel.dart';
import '../models/calender_event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final List<DateTime> _daysOfWeek;
  int _selectedDayIndex = 0;

  final List<String> _hours = [
    '12:00 AM',
    '01:00 AM',
    '02:00 AM',
    '03:00 AM',
    '04:00 AM',
    '05:00 AM',
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
    '10:00 PM',
    '11:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Calculate the start of the week (Monday)
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    _daysOfWeek = List.generate(7, (index) {
      return monday.add(Duration(days: index));
    });

    _selectedDayIndex = currentWeekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityViewModel>();
    final workflow = context.watch<WorkflowViewModel>();
    final events = workflow.getFilteredCalendar(
      gmailConnected: connectivity.isGmailConnected,
      m365Connected: connectivity.isM365Connected,
    );

    final selectedDate = _daysOfWeek[_selectedDayIndex];
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final dayEvents = events.where((e) => e.date == selectedDateStr).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          DateFormat('MMMM yyyy').format(selectedDate),
          style: const TextStyle(
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
                  final dayDateTime = _daysOfWeek[index];
                  final weekdayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final dayName = weekdayNames[dayDateTime.weekday - 1];
                  final dateStr = dayDateTime.day.toString();
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
                            dayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateStr,
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
                final hourNum = index;

                final slotEvents = dayEvents.where((e) {
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
