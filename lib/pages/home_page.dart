import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/task_card.dart';
import '../core/notification_service.dart';
import 'add_task_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onThemeChanged;
  final int currentThemeIndex;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.currentThemeIndex,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box _tasksBox = Hive.box('tasks');
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final data = _tasksBox.keys.map((key) {
      final v = _tasksBox.get(key);
      return {
        'key': key,
        'title': v['title'],
        'description': v['description'] ?? '',
        'isCompleted': v['isCompleted'] ?? false,
        'priority': v['priority'] ?? 'medium',
        'dateTime': v['dateTime'] ?? DateTime.now().toIso8601String(),
      };
    }).toList();

    data.sort(
      (a, b) => DateTime.parse(
        a['dateTime'],
      ).compareTo(DateTime.parse(b['dateTime'])),
    );

    setState(() => _tasks = List<Map<String, dynamic>>.from(data));
  }

  Future<void> _deleteTask(int key) async {
    _tasksBox.delete(key);
    await NotificationService.cancelNotification(key);
    _loadTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Compromisso removido'),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  void _toggleComplete(int key) {
    final t = _tasksBox.get(key);
    t['isCompleted'] = !t['isCompleted'];
    _tasksBox.put(key, t);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Mordomo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(
                  currentThemeIndex: widget.currentThemeIndex,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                return TaskCard(
                  title: t['title'],
                  description: t['description'],
                  isCompleted: t['isCompleted'],
                  priority: t['priority'],
                  dateTime: DateTime.parse(t['dateTime']),
                  onToggleComplete: () => _toggleComplete(t['key']),
                  onDelete: () => _deleteTask(t['key']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          _loadTasks();
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Compromisso'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.event_available,
          size: 90,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Nenhum compromisso',
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toque no + para adicionar',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  );
}
