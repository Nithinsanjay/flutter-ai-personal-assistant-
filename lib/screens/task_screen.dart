import 'package:flutter/material.dart';
import '../state/app_state.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    final todayTasks = state.tasks.where((t) => t.status == 'Today').toList();
    final inProgressTasks = state.tasks.where((t) => t.status == 'InProgress').toList();
    final completedTasks = state.tasks.where((t) => t.status == 'Completed').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Tasks',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF4F46E5),
            labelColor: Color(0xFF4F46E5),
            unselectedLabelColor: Color(0xFF64748B),
            tabs: [
              Tab(text: 'Board'),
              Tab(text: 'List'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('Today', todayTasks.length, Colors.blue),
                const SizedBox(height: 8),
                ...todayTasks.map((t) => _buildTaskCard(context, t, state)),
                const SizedBox(height: 24),
                
                _buildSectionHeader('In Progress', inProgressTasks.length, Colors.amber),
                const SizedBox(height: 8),
                ...inProgressTasks.map((t) => _buildTaskCard(context, t, state)),
                const SizedBox(height: 24),
                
                _buildSectionHeader('Completed', completedTasks.length, Colors.green),
                const SizedBox(height: 8),
                ...completedTasks.map((t) => _buildTaskCard(context, t, state)),
              ],
            ),
            
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return _buildTaskCard(context, task, state);
              },
            ),
            
            completedTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No completed tasks yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: completedTasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = completedTasks[index];
                      return _buildTaskCard(context, task, state);
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context, state),
          backgroundColor: const Color(0xFF4F46E5),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task, AppState state) {
    Color priorityColor;
    if (task.priority == 'High') {
      priorityColor = Colors.red;
    } else if (task.priority == 'Medium') {
      priorityColor = Colors.amber;
    } else {
      priorityColor = Colors.blue;
    }

    final isCompleted = task.status == 'Completed';

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.amber,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          state.updateTaskStatus(task.id, 'Completed');
        } else {
          state.updateTaskStatus(task.id, 'InProgress');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (val) {
                state.updateTaskStatus(
                  task.id,
                  val == true ? 'Completed' : (task.status == 'Completed' ? 'Today' : 'Completed'),
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
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, color: Colors.grey, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        task.time,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      if (task.sourceEmailId != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.email, color: Color(0xFF4F46E5), size: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 18),
              color: Colors.white,
              onSelected: (value) {
                state.updateTaskStatus(task.id, value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Today',
                  child: Text('Move to Today', style: TextStyle(color: Color(0xFF0F172A))),
                ),
                const PopupMenuItem(
                  value: 'InProgress',
                  child: Text('Move to In Progress', style: TextStyle(color: Color(0xFF0F172A))),
                ),
                const PopupMenuItem(
                  value: 'Completed',
                  child: Text('Complete Task', style: TextStyle(color: Color(0xFF0F172A))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    String priority = 'High';
    String time = '02:00 PM';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Create New Task', style: TextStyle(color: Color(0xFF0F172A))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Task Title',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Priority:', style: TextStyle(color: Color(0xFF0F172A))),
                      DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: priority,
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              priority = val;
                            });
                          }
                        },
                        items: ['High', 'Medium', 'Low'].map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val, style: const TextStyle(color: Color(0xFF0F172A))),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Time:', style: TextStyle(color: Color(0xFF0F172A))),
                      TextButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            setDialogState(() {
                              time = selectedTime.format(context);
                            });
                          }
                        },
                        child: Text(time, style: const TextStyle(color: Color(0xFF4F46E5))),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      state.addManualTask(titleController.text, time, priority, 'Today');
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task added successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
                  child: const Text('Create', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
