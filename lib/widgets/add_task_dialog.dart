import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/workflow_viewmodel.dart';
import '../core/responsive.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  String _priority = 'High';
  String _time = '02:00 PM';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.read<WorkflowViewModel>();

    return AlertDialog(
      backgroundColor: Colors.white,
      scrollable: true,
      title: Text(
        'Create New Task',
        style: TextStyle(
          color: const Color(0xFF0F172A),
          fontSize: context.sp(18),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: context.w(300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: context.sp(14),
              ),
              decoration: InputDecoration(
                hintText: 'Task Title',
                hintStyle: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: context.sp(14),
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: context.h(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: context.h(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Priority:',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: context.sp(14),
                  ),
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: _priority,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _priority = val;
                      });
                    }
                  },
                  items: ['High', 'Medium', 'Low'].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(
                        val,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: context.sp(14),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time:',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: context.sp(14),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        _time = selectedTime.format(context);
                      });
                    }
                  },
                  child: Text(
                    _time,
                    style: TextStyle(
                      color: const Color(0xFF4F46E5),
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
              fontSize: context.sp(14),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              workflow.addManualTask(
                _titleController.text,
                _time,
                _priority,
                'Pending',
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task added successfully!'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: EdgeInsets.symmetric(
              horizontal: context.w(16),
              vertical: context.h(8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Create',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
