import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/providers/task_provider.dart';
import 'package:to_do_app/utils/constants.dart';
import 'package:to_do_app/widgets/task_list.dart';
import 'package:to_do_app/widgets/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapılacaklar', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.disabled,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Yapılacak'),
            Tab(text: 'Tamamlanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Tasks
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              return TaskList(tasks: taskProvider.tasks);
            },
          ),
          // Pending Tasks
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              return taskProvider.pendingTasks.isEmpty
                  ? _buildEmptyState('Henüz yapılacak görev yok')
                  : TaskList(tasks: taskProvider.pendingTasks);
            },
          ),
          // Completed Tasks
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              if (taskProvider.completedTasks.isEmpty) {
                return _buildEmptyState('Henüz tamamlanan görev yok');
              }
              return Column(
                children: [
                  Expanded(
                    child: TaskList(tasks: taskProvider.completedTasks),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _showClearCompletedDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.onError,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Temizle'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.disabled,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tamamlananları Temizle'),
        content: const Text('Tamamlanan tüm görevleri silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().clearCompleted();
              Navigator.of(context).pop();
            },
            child: const Text('Temizle', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
