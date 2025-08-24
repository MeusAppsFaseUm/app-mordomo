import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/notification_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final Box _box = Hive.box('tasks');

  String _priority = 'medium';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _isSaving = false;

  Future<void> _save() async {
    if (_isSaving) return;
    _isSaving = true;

    if (_title.text.trim().isEmpty) {
      _isSaving = false;
      _snack(
        'Por favor, informe um título para o compromisso',
        Colors.red,
        Icons.warning,
      );
      return;
    }

    try {
      final dateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

      if (dateTime.isBefore(DateTime.now())) {
        _isSaving = false;
        _snack(
          'A data deve ser no futuro para agendar lembretes',
          Colors.orange,
          Icons.schedule,
        );
        return;
      }

      final task = {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'isCompleted': false,
        'priority': _priority,
        'dateTime': dateTime.toIso8601String(),
        'hasNotification': true,
      };

      final key = await _box.add(task);

      final notificationsEnabled =
          await NotificationService.areNotificationsEnabled();

      bool notificationScheduled = false;
      if (notificationsEnabled) {
        notificationScheduled = await NotificationService.scheduleNotification(
          id: key,
          title: task['title'] as String,
          body: task['description'] as String,
          scheduledDate: dateTime,
        );
      }

      if (notificationScheduled) {
        _snack(
          'Compromisso agendado com lembrete!',
          Colors.green,
          Icons.check_circle,
        );
      } else if (!notificationsEnabled) {
        _snack(
          'Compromisso salvo, mas notificações não estão habilitadas',
          Colors.orange,
          Icons.notifications_off,
        );
      } else {
        _snack('Compromisso salvo!', Colors.green, Icons.check);
      }

      if (_box.length == 1) {
        _showFirstTimeDialog();
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Erro ao salvar compromisso: $e');
      _snack(
        'Erro ao salvar compromisso. Tente novamente.',
        Colors.red,
        Icons.error,
      );
    } finally {
      _isSaving = false;
    }
  }

  void _snack(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFirstTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.orange),
            SizedBox(width: 8),
            Text('Dicas Importantes'),
          ],
        ),
        content: const Text(
          'Para garantir que os lembretes funcionem perfeitamente:\n\n'
          '1. Permita notificações para este app\n'
          '2. Nas configurações do celular, vá em:\n'
          '   • Apps > Mordomo > Bateria\n'
          '   • Escolha "Sem restrições"\n\n'
          '3. Mantenha o volume de notificações ligado\n\n'
          'Isso garante que você seja avisado mesmo com o app fechado!',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showNotificationSettings();
            },
            child: const Text('Ver Configurações'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status das Notificações'),
        content: FutureBuilder<bool>(
          future: NotificationService.areNotificationsEnabled(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Verificando...'),
                ],
              );
            }

            final enabled = snapshot.data ?? false;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      enabled ? Icons.check_circle : Icons.error,
                      color: enabled ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enabled
                            ? 'Notificações estão habilitadas!'
                            : 'Notificações estão desabilitadas',
                        style: TextStyle(
                          color: enabled ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!enabled) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Vá em Configurações > Apps > Mordomo > Notificações e ative.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Compromisso'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton.filled(
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 20),
              onPressed: _isSaving ? null : _save,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Título do Compromisso'),
              const SizedBox(height: 8),
              _input(_title, 'Ex: Consulta médica, Tomar remédio...'),
              const SizedBox(height: 24),
              _label('Descrição (opcional)'),
              const SizedBox(height: 8),
              _input(
                _desc,
                'Detalhes adicionais sobre o compromisso...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _label('Importância'),
              const SizedBox(height: 8),
              _priorityDropdown(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _dateSection()),
                  const SizedBox(width: 16),
                  Expanded(child: _timeSection()),
                ],
              ),
              const SizedBox(height: 40),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  Widget _input(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: maxLines > 1
          ? const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description),
            )
          : const Icon(Icons.event_note),
    ),
  );

  Widget _priorityDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: DropdownButton<String>(
      value: _priority,
      isExpanded: true,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down),
      items: const [
        DropdownMenuItem(
          value: 'low',
          child: Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 12),
              SizedBox(width: 8),
              Text('Baixa'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'medium',
          child: Row(
            children: [
              Icon(Icons.circle, color: Colors.orange, size: 12),
              SizedBox(width: 8),
              Text('Média'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'high',
          child: Row(
            children: [
              Icon(Icons.circle, color: Colors.red, size: 12),
              SizedBox(width: 8),
              Text('Alta'),
            ],
          ),
        ),
      ],
      onChanged: (v) => setState(() => _priority = v!),
    ),
  );

  Widget _dateSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Data',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      _pickerTile(
        icon: Icons.calendar_today,
        text:
            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
        onTap: _pickDate,
      ),
    ],
  );

  Widget _timeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Hora',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      _pickerTile(
        icon: Icons.access_time,
        text: _time.format(context),
        onTap: _pickTime,
      ),
    ],
  );

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: Icon(icon),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  Widget _saveButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.save, size: 24),
      label: Text(
        _isSaving ? 'Salvando...' : 'Salvar Compromisso',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }
}
