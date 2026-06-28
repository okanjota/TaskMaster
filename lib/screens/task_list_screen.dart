import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback onTaskUpdated;

  const TaskListScreen(
      {super.key, required this.tasks, required this.onTaskUpdated});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _filter = 'Todas';

  List<Task> get _filteredTasks {
    final now = DateTime.now();
    return widget.tasks.where((task) {
      if (_filter == 'Hoje') {
        final d = task.dueDate;
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }
      if (_filter == 'Concluídas') return task.isCompleted;
      if (_filter == 'Pendentes') return !task.isCompleted;
      return true;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.alta:
        return Colors.red;
      case Priority.media:
        return Colors.orange;
      case Priority.baixa:
        return Colors.green;
    }
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.alta:
        return 'Alta';
      case Priority.media:
        return 'Média';
      case Priority.baixa:
        return 'Baixa';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) =>
                ['Todas', 'Hoje', 'Pendentes', 'Concluídas']
                    .map((e) => PopupMenuItem(
                          value: e,
                          child: Row(
                            children: [
                              if (_filter == e)
                                const Icon(Icons.check,
                                    size: 16, color: Color(0xFF6B4EFF)),
                              if (_filter == e) const SizedBox(width: 4),
                              Text(e),
                            ],
                          ),
                        ))
                    .toList(),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    _filter == 'Concluídas'
                        ? 'Nenhuma tarefa concluída ainda'
                        : 'Nenhuma tarefa encontrada',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final task = filtered[index];
                return Slidable(
                  key: Key(task.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          setState(() => task.isCompleted = !task.isCompleted);
                          widget.onTaskUpdated();
                        },
                        backgroundColor:
                            task.isCompleted ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        icon: task.isCompleted ? Icons.undo : Icons.check,
                        label: task.isCompleted ? 'Desfazer' : 'Concluir',
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          widget.tasks.remove(task);
                          widget.onTaskUpdated();
                          setState(() {});
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Excluir',
                      ),
                    ],
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: const Color(0xFF6B4EFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (_) {
                          setState(() => task.isCompleted = !task.isCompleted);
                          widget.onTaskUpdated();
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color:
                              task.isCompleted ? Colors.grey : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                          '${task.category} • ${_formatDate(task.dueDate)}',
                          style: const TextStyle(fontSize: 13)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _priorityColor(task.priority)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _priorityLabel(task.priority),
                          style: TextStyle(
                              color: _priorityColor(task.priority),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff < 0) return 'Atrasada';
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
