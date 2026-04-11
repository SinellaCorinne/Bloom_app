import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tasks.dart';
import '../providers/task_provider.dart';
import '../theme.dart';
import 'add_task_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({required this.task, super.key});

  // Fonction pour envoyer les détails sur WhatsApp
  Future<void> shareTaskOnWhatsApp(Task task) async {
    final String message = "🌸 *Bloom Task* 🌸\n\n"
        "📌 *Titre :* ${task.title}\n"
        "📅 *Date :* ${task.formattedDate}\n"
        "⚠️ *Priorité :* ${task.priorityLabel}\n\n"
        "Envoyé depuis mon application Bloom.";

    final String url = "https://wa.me/?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Impossible d'ouvrir WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new, color: cs.onSurface, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Task Details',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // ✅ BOUTON PARTAGER WHATSAPP
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:  Icon(Icons.share_outlined, color: cs.primary, size: 18),
              ),
              onPressed: () => shareTaskOnWhatsApp(task),
            ),
          ),

          // BOUTON MODIFIER
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.edit_outlined, color: cs.onSurface, size: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(
                      taskToEdit: task,
                      onTaskAdded: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            _InfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'DUE DATE',
              value: task.formattedDate,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Upcoming',
                  style: TextStyle(
                    color:  Theme.of(context).cardColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.notifications_outlined,
              label: 'REMINDER',
              value: '${task.formattedTime}, ${task.formattedDate}',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: cs.primary,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: task.priorityBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  task.priorityLabel,
                  style: TextStyle(
                    color: task.priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'NOTES',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                task.notes?.isNotEmpty == true ? task.notes! : task.description,
                style: TextStyle(color: cs.onSurface, fontSize: 14, height: 1.5),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TaskProvider>().toggleTask(task.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Tâche mise à jour !')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary, // La couleur du thème
                  foregroundColor: Colors.white, // Couleur du texte
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Terminé',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                shape: BoxShape.circle),
            child:  Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}