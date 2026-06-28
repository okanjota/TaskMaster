import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskScreen({super.key, required this.onTaskAdded});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  Priority priority = Priority.media;
  String category = 'Trabalho';
  DateTime dueDate = DateTime.now().add(const Duration(days: 1));

  final categories = ['Trabalho', 'Pessoal', 'Estudo', 'Saúde', 'Outros'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Tarefa'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
                onChanged: (value) => title = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.notes),
                ),
                maxLines: 3,
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 20),
              const Text('Prioridade',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _priorityButton(Priority.alta, 'Alta'),
                  const SizedBox(width: 8),
                  _priorityButton(Priority.media, 'Média'),
                  const SizedBox(width: 8),
                  _priorityButton(Priority.baixa, 'Baixa'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Categoria',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .map((cat) => ChoiceChip(
                          label: Text(cat),
                          selected: category == cat,
                          selectedColor:
                              const Color(0xFF6B4EFF).withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                              color: category == cat
                                  ? const Color(0xFF6B4EFF)
                                  : Colors.black87,
                              fontWeight: category == cat
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                          onSelected: (selected) =>
                              setState(() => category = cat),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today,
                      color: Color(0xFF6B4EFF)),
                  title: const Text('Data de vencimento'),
                  subtitle: Text(
                    '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF6B4EFF)),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => dueDate = picked);
                  },
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final task = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title.trim(),
                      description: description.trim(),
                      priority: priority,
                      category: category,
                      dueDate: dueDate,
                    );
                    widget.onTaskAdded(task);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Salvar Tarefa',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityButton(Priority p, String label) {
    final selected = priority == p;
    final color = _priorityColor(p);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => priority = p),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? color : color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
