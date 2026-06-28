import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'focus_mode_screen.dart';
import 'calendar_screen.dart';
import 'add_task_screen.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadSampleTasks();
  }

  void _loadSampleTasks() {
    tasks = [
      Task(
        id: '1',
        title: 'Reunião com time',
        description: 'Discutir projeto TaskMaster',
        priority: Priority.alta,
        category: 'Trabalho',
        dueDate: DateTime.now().add(const Duration(hours: 3)),
      ),
      Task(
        id: '2',
        title: 'Finalizar relatório',
        description: 'Relatório trimestral de resultados',
        priority: Priority.media,
        category: 'Trabalho',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Task(
        id: '3',
        title: 'Academia',
        description: 'Treino de musculação',
        priority: Priority.baixa,
        category: 'Saúde',
        dueDate: DateTime.now(),
      ),
    ];
  }

  void _addTask(Task task) {
    setState(() => tasks.add(task));
  }

  void _updateTasks() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardContent(tasks: tasks),
      TaskListScreen(tasks: tasks, onTaskUpdated: _updateTasks),
      FocusModeScreen(tasks: tasks),
      CalendarScreen(tasks: tasks),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF6B4EFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tarefas'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Foco'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6B4EFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(onTaskAdded: _addTask),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final List<Task> tasks;
  const DashboardContent({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayTasks = tasks.where((t) {
      final d = t.dueDate;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Olá, Produtivo! 👋',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Text('Aqui está seu dia',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildSummaryCard('Hoje', '${todayTasks.length} tarefa${todayTasks.length == 1 ? '' : 's'}',
                    Icons.today, Colors.orange),
                const SizedBox(width: 16),
                _buildSummaryCard('Concluídas', '$completedCount/${tasks.length}',
                    Icons.check_circle, Colors.green),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Próximas tarefas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: pendingTasks.isEmpty
                  ? const Center(
                      child: Text('Nenhuma tarefa pendente! 🎉',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: pendingTasks.length,
                      itemBuilder: (context, index) {
                        final task = pendingTasks[index];
                        final color = task.priority == Priority.alta
                            ? Colors.red
                            : task.priority == Priority.media
                                ? Colors.orange
                                : Colors.grey;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(Icons.radio_button_unchecked, color: color),
                            title: Text(task.title,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(
                                '${task.category} • ${_formatDate(task.dueDate)}'),
                            trailing: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff < 0) return 'Atrasada';
    return '${date.day}/${date.month}';
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
