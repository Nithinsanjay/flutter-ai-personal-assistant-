import 'package:ai_personal_asst/views/email_screen.dart';
import 'package:ai_personal_asst/views/task_screen.dart';
import 'package:ai_personal_asst/widgets/add_task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/connectivity_viewmodel.dart';
import '../viewmodels/workflow_viewmodel.dart';
import '../viewmodels/model_viewmodel.dart';
import 'calendar_screen.dart';
import '../models/task_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityViewModel>();
    final workflow = context.watch<WorkflowViewModel>();
    final today = DateTime.now();

    final totalEmails = workflow
        .getFilteredEmails(
          gmailConnected: connectivity.isGmailConnected,
          m365Connected: connectivity.isM365Connected,
        )
        .length;

    final highPriorityTasks = workflow.tasks
        .where((t) => t.priority == 'High' && t.status != 'Completed')
        .length;

    final todayUnfinishedTasks = workflow.tasks.where((task) {
      final isToday = DateUtils.isSameDay(task.dueDate, today);
      final isUnfinished =
          task.status == 'Pending' || task.status == 'InProgress';
      return isToday && isUnfinished;
    }).length;

    final overdueTasks = workflow.tasks.where((task) {
      final isOverdue = task.dueDate.isBefore(today);
      final isUnfinished =
          task.status == 'Pending' || task.status == 'InProgress';
      return isOverdue && isUnfinished;
    }).length;

    final todayTasks = workflow.tasks
        .where((task) {
          final isToday = DateUtils.isSameDay(task.dueDate, today);
          final isUnfinished =
              task.status == 'Pending' || task.status == 'InProgress';
          return isToday && isUnfinished;
        })
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE0E7FF),
              child: const Text(
                'P',
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, ${connectivity.userName} 👋',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${DateTime.now().day}-${DateFormat('MMMM').format(DateTime.now())}-${DateTime.now().year}',

                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF0F172A),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF0F172A),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your daily brief is updated.'),
                  backgroundColor: Color(0xFF4F46E5),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  context: context,
                  icon: Icons.email_outlined,
                  count: '$totalEmails',
                  label: 'Emails Surfaced',
                  accentColor: Colors.blue,
                  widgetScreen: EmailInboxScreen(),
                ),
                _buildStatCard(
                  context: context,
                  icon: Icons.assignment_late_outlined,
                  count: '$highPriorityTasks',
                  label: 'High Priority Tasks',
                  accentColor: Colors.red,
                  widgetScreen: TaskScreen(),
                ),
                _buildStatCard(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  count: '$todayUnfinishedTasks',
                  label: "Today's Unfinished Tasks",
                  accentColor: Colors.green,
                  widgetScreen: TaskScreen(),
                ),
                _buildStatCard(
                  context: context,
                  icon: Icons.warning_amber_rounded,
                  count: '$overdueTasks',
                  label: 'Overdue Tasks',
                  accentColor: Colors.amber,
                  widgetScreen: TaskScreen(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TaskScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = todayTasks[index];
                return _buildTaskTile(context, task, workflow);
              },
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    Icons.question_answer_outlined,
                    'Ask AI',
                    () {
                      context.read<ConnectivityViewModel>().setTabIndex(3);
                    },
                  ),
                  _buildActionButton(
                    context,
                    Icons.add_task_outlined,
                    'Create Task',
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddTaskDialog(),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    Icons.sync_outlined,
                    'Sync now',
                    () async {
                      if (!connectivity.isGmailConnected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No connected accounts to sync. Please connect Gmail in Settings.',
                            ),
                            backgroundColor: Color(0xFFE11D48),
                          ),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Synchronizing Gmail messages...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      try {
                        final isGmailConnected = connectivity.isGmailConnected;
                        final isAiActive =
                            context.read<ModelViewModel>().connectedModel !=
                            null;
                        await workflow.syncGmail(
                          gmailConnected: isGmailConnected,
                          aiActive: isAiActive,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gmail synchronized successfully!'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sync failed: ${e.toString().replaceAll('Exception:', '').trim()}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String count,
    required String label,
    required Color accentColor,
    Widget? widgetScreen,
  }) {
    return GestureDetector(
      onTap: () {
        if (widgetScreen != null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => widgetScreen));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor, size: 20),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    TaskItem task,
    WorkflowViewModel workflow,
  ) {
    Color priorityColor;
    if (task.priority == 'High') {
      priorityColor = Colors.red;
    } else if (task.priority == 'Medium') {
      priorityColor = Colors.amber;
    } else {
      priorityColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.status == 'Completed',
            onChanged: (val) {
              workflow.updateTaskStatus(
                task.id,
                val == true ? 'Completed' : 'Pending',
              );
            },
            activeColor: const Color(0xFF4F46E5),
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                    decoration: task.status == 'Completed'
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.priority,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: Colors.grey, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      task.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
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

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4F46E5), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
