import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bloom_app/screens/profile.dart';
import 'package:bloom_app/screens/task_details.dart';
import 'package:bloom_app/screens/add_task_screen.dart';
import '../models/tasks.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final List<String> _tabs = ['Today', 'Upcoming', 'Completed'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les tâches au démarrage (priorité cache puis API)
    Future.microtask(() => context.read<TaskProvider>().loadTasks());
  }

  List<Task> _filteredTasks(List<Task> allTasks) {
    final now = DateTime.now();
    List<Task> result;
    switch (_currentTab) {
      case 0: // Today
        result = allTasks.where((t) =>
        !t.isDone &&
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day).toList();
        break;
      case 1: // Upcoming
        result = allTasks.where((t) =>
        !t.isDone &&
            t.date.isAfter(DateTime(now.year, now.month, now.day + 1))).toList();
        break;
      case 2: // Completed
        result = allTasks.where((t) => t.isDone).toList();
        break;
      default:
        result = allTasks;
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final authProvider = context.watch<AuthProvider>();
    final allTasks = taskProvider.tasks;
    final filtered = _filteredTasks(allTasks);

    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Bloom',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: cs.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.cardBg(context),
                child: Icon(Icons.person_outline, color: cs.primary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _currentTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _currentTab = i),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 28),
                      child: Column(
                        children: [
                          Text(
                            _tabs[i],
                            style: TextStyle(
                              color: selected ? cs.primary : cs.onSurfaceVariant,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (selected)
                            Container(
                              height: 2,
                              width: 30,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // ── Greeting card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${authProvider.userName}! 👋',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have ${allTasks.where((t) => !t.isDone).length} tasks to finish today.',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bandeau d'erreur (Mode Hors-ligne) ──
            if (taskProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          taskProvider.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                        onPressed: () => taskProvider.loadTasks(),
                      )
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ── Task list ──
            Expanded(
              child: taskProvider.isLoading && allTasks.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? const Center(child: Text('Aucune tâche 🌸'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final task = filtered[index];
                  return Dismissible(
                    key: Key(task.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) => context.read<TaskProvider>().deleteTask(task.id),
                    child: TaskTile(
                      task: task,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)),
                      ),
                      onToggle: () => context.read<TaskProvider>().toggleTask(task.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.primary,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTaskScreen(onTaskAdded: () => setState(() {})),
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}