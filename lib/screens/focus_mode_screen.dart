import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';

class FocusModeScreen extends StatefulWidget {
  final List<Task> tasks;
  const FocusModeScreen({super.key, required this.tasks});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  static const int _defaultMinutes = 25;
  int _totalSeconds = _defaultMinutes * 60;
  int _seconds = _defaultMinutes * 60;
  Timer? _timer;
  bool _isRunning = false;
  int _sessionsCompleted = 0;
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    _selectedTask = widget.tasks.where((t) => !t.isCompleted).isNotEmpty
        ? widget.tasks.where((t) => !t.isCompleted).first
        : null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer?.cancel();
          _timer = null;
          _isRunning = false;
          _sessionsCompleted++;
          _showCompletionDialog();
        }
      });
    });
    setState(() => _isRunning = true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() => _seconds = _totalSeconds);
  }

  void _setDuration(int minutes) {
    _pauseTimer();
    setState(() {
      _totalSeconds = minutes * 60;
      _seconds = _totalSeconds;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sessão concluída! 🎉'),
        content: const Text('Ótimo trabalho! Faça uma pausa de 5 minutos.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setDuration(5);
            },
            child: const Text('Pausa 5 min'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setDuration(_defaultMinutes);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4EFF)),
            child: const Text('Nova sessão',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    final progress = _seconds / _totalSeconds;
    final pendingTasks =
        widget.tasks.where((t) => !t.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Modo Foco',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Task selector
              if (pendingTasks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<Task>(
                    value: _selectedTask,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF16213E),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    hint: const Text('Selecionar tarefa',
                        style: TextStyle(color: Colors.white60)),
                    items: pendingTasks
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.title,
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (t) => setState(() => _selectedTask = t),
                  ),
                )
              else
                const Text('Nenhuma tarefa pendente',
                    style: TextStyle(color: Colors.white60)),

              const SizedBox(height: 32),

              // Duration selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _durationChip(15, '15min'),
                  const SizedBox(width: 10),
                  _durationChip(25, '25min'),
                  const SizedBox(width: 10),
                  _durationChip(45, '45min'),
                  const SizedBox(width: 10),
                  _durationChip(60, '60min'),
                ],
              ),

              const SizedBox(height: 40),

              // Timer circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(
                        _isRunning
                            ? const Color(0xFF6B4EFF)
                            : const Color(0xFF9B7FFF),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$minutes:$secs',
                        style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2),
                      ),
                      Text(
                        _isRunning ? 'Em foco...' : 'Pronto',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(_isRunning ? 'Pausar' : 'Iniciar',
                        style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isRunning ? Colors.orange : const Color(0xFF6B4EFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    label: const Text('Reiniciar',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sessions counter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Sessões concluídas: $_sessionsCompleted',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationChip(int minutes, String label) {
    final selected = _totalSeconds == minutes * 60;
    return GestureDetector(
      onTap: () => _setDuration(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6B4EFF) : Colors.white12,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : Colors.white54,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13),
        ),
      ),
    );
  }
}
