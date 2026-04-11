import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tasks.dart';
import '../providers/task_provider.dart';
import '../theme.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback onTaskAdded;
  final Task? taskToEdit;

  const AddTaskScreen({required this.onTaskAdded, this.taskToEdit, super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late String _selectedPriority;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final t = widget.taskToEdit;
    _titleController = TextEditingController(text: t?.title ?? '');
    _notesController = TextEditingController(text: t?.notes ?? '');
    _selectedPriority = t?.priority ?? 'Medium';
    _selectedDate = t?.date ?? DateTime.now();
    _selectedTime = t != null
        ? TimeOfDay(hour: t.date.hour, minute: t.date.minute)
        : TimeOfDay.now();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _pickTime() async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: cs.brightness == Brightness.dark
              ? ColorScheme.dark(primary: cs.primary, onPrimary: Colors.white)
              : ColorScheme.light(primary: cs.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Color _priorityBg(String p) {
    switch (p) {
      case 'High': return AppTheme.priorityHighBg;
      case 'Medium': return AppTheme.priorityMediumBg;
      case 'Low': return AppTheme.priorityLowBg;
      default: return AppTheme.priorityMediumBg;
    }
  }

  Color _priorityFg(String p) {
    switch (p) {
      case 'High': return AppTheme.priorityHighText;
      case 'Medium': return AppTheme.priorityMediumText;
      case 'Low': return AppTheme.priorityLowText;
      default: return AppTheme.priorityMediumText;
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un titre')),
      );
      return;
    }

    final provider = context.read<TaskProvider>();
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final task = Task(
      id: widget.taskToEdit?.id ?? provider.nextId,
      title: _titleController.text.trim(),
      description: _notesController.text.trim(),
      date: dateTime,
      priority: _selectedPriority,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.taskToEdit != null) {
      await provider.updateTask(widget.taskToEdit!.id, task);
    } else {
      await provider.addTask(task);
    }

    widget.onTaskAdded();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.taskToEdit != null ? '✅ Tâche modifiée !' : '✅ Tâche enregistrée !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.taskToEdit != null;

    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new,
                color: cs.onSurface, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Task' : 'New Task',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _save,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Title',
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            _WhiteField(
              controller: _titleController,
              hintText: "What's blooming today?",
            ),
            const SizedBox(height: 20),

            Text('Priority',
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 10),
            Row(
              children: ['High', 'Medium', 'Low'].map((p) {
                final selected = _selectedPriority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? _priorityBg(p) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: selected
                            ? Border.all(color: _priorityFg(p), width: 1.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        p,
                        style: TextStyle(
                          color: selected ? _priorityFg(p) : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Text('Notes & Petals',
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 8),
            _WhiteField(
              controller: _notesController,
              hintText: 'Add more details...',
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            Text('Date',
                style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Schedule',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15, color: cs.onSurface)),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: cs.primary),
                            onPressed: () => setState(() {
                              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                            }),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          Text(
                            '${months[_selectedDate.month - 1]} ${_selectedDate.year}',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: cs.onSurface),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: cs.primary),
                            onPressed: () => setState(() {
                              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                            }),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map((d) => SizedBox(
                      width: 32,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                    )).toList(),
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (_, i) {
                      final day = i + 1;
                      final isSelected = day == _selectedDate.day;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                        }),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primary : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isSelected ? Colors.white : cs.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: cs.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(fontSize: 15, color: cs.onSurface),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isEdit ? 'Mettre à jour' : 'Enregistrer',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _WhiteField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _WhiteField({required this.controller, required this.hintText, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}