import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/providers/task_provider.dart';
import 'package:to_do_app/utils/constants.dart';
import 'package:to_do_app/widgets/edit_task_dialog.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Görev bulunamadı'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TaskItem(
          key: ValueKey(task.id),
          task: task,
          onEdit: () => _showEditDialog(context, task),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(task: task),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;

  const _TaskItem({super.key, required this.task, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: AppColors.onError),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Görevi Sil'),
                content: const Text(
                  'Bu görevi silmek istediğinize emin misiniz?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Sil',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        context.read<TaskProvider>().deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görev silindi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () {
            context.read<TaskProvider>().toggleTaskStatus(task.id);
          },
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          task.isCompleted
                              ? AppColors.primary
                              : AppColors.disabled,
                      width: 2,
                    ),
                    color:
                        task.isCompleted
                            ? AppColors.primary
                            : Colors.transparent,
                  ),
                  child:
                      task.isCompleted
                          ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.onPrimary,
                          )
                          : null,
                ),
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              task.isCompleted
                                  ? AppColors.disabled
                                  : AppColors.onBackground,
                        ),
                      ),
                      if (task.description?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.disabled,
                              decoration:
                                  task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
