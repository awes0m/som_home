import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/providers/tasks_provider.dart';
import '../core/models/models.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  bool _showCompleted = false;

  void _showAddTaskDialog([Task? task]) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final notesController = TextEditingController(text: task?.notes ?? '');
    final categoryController = TextEditingController(text: task?.category ?? '');
    DateTime? selectedDate = task?.dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(task == null ? 'Add Task' : 'Edit Task'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title*'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                        : 'Not set'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => selectedDate = date);
                      }
                    },
                  ),
                  if (selectedDate != null)
                    TextButton(
                      onPressed: () => setDialogState(() => selectedDate = null),
                      child: const Text('Clear Date'),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  final provider = Provider.of<TasksProvider>(context, listen: false);
                  if (task == null) {
                    provider.addTask(Task(
                      title: title,
                      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                      dueDate: selectedDate,
                    ));
                  } else {
                    task.title = title;
                    task.notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();
                    task.category = categoryController.text.trim().isEmpty ? null : categoryController.text.trim();
                    task.dueDate = selectedDate;
                    provider.updateTask(task);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(task == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<TasksProvider>(
        builder: (context, provider, _) {
          final tasks = _showCompleted ? provider.completedTasks : provider.activeTasks;
          
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.7),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tasks',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('Active'), icon: Icon(Icons.radio_button_unchecked)),
                            ButtonSegment(value: true, label: Text('Completed'), icon: Icon(Icons.check_circle)),
                          ],
                          selected: {_showCompleted},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() => _showCompleted = newSelection.first);
                          },
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: () => _showAddTaskDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Task'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Active',
                            count: provider.activeTasks.length,
                            icon: Icons.pending_actions,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Completed',
                            count: provider.completedTasks.length,
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Overdue',
                            count: provider.activeTasks.where((t) =>
                              t.dueDate != null && t.dueDate!.isBefore(DateTime.now())
                            ).length,
                            icon: Icons.warning,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tasks List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showCompleted ? Icons.check_circle_outline : Icons.task_alt,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showCompleted ? 'No completed tasks' : 'No active tasks',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _TaskTile(
                            task: task,
                            onToggle: () => provider.toggleTask(task.id),
                            onEdit: () => _showAddTaskDialog(task),
                            onDelete: () => provider.deleteTask(task.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null && 
                      task.dueDate!.isBefore(DateTime.now()) && 
                      !task.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                task.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : null,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (task.category != null)
                  Chip(
                    label: Text(task.category!),
                    visualDensity: VisualDensity.compact,
                  ),
                if (task.category != null && task.dueDate != null)
                  const SizedBox(width: 8),
                if (task.dueDate != null)
                  Chip(
                    label: Text(DateFormat('MMM dd').format(task.dueDate!)),
                    avatar: Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isOverdue ? Colors.red : null,
                    ),
                    backgroundColor: isOverdue ? Colors.red.shade50 : null,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: onEdit,
              child: const Row(
                children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            PopupMenuItem(
              onTap: onDelete,
              child: const Row(
                children: [Icon(Icons.delete, size: 20), SizedBox(width: 8), Text('Delete')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}