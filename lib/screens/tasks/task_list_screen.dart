import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/task_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import 'task_detail_screen.dart';

enum _SortMode { dueDate, priority, created }

extension on _SortMode {
  String get label => switch (this) {
        _SortMode.dueDate => 'نزدیک‌ترین موعد',
        _SortMode.priority => 'بیشترین اولویت',
        _SortMode.created => 'تازه‌ترین',
      };
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus? _statusFilter;
  int? _categoryFilter;
  _SortMode _sort = _SortMode.dueDate;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Task> _apply(List<Task> input) {
    var tasks = input;
    if (_statusFilter != null) {
      tasks = tasks.where((t) => t.status == _statusFilter).toList();
    }
    if (_categoryFilter != null) {
      tasks = tasks.where((t) => t.categoryId == _categoryFilter).toList();
    }
    if (_query.trim().isNotEmpty) {
      final q = _query.trim();
      tasks = tasks
          .where((t) =>
              t.title.contains(q) || t.description.contains(q))
          .toList();
    }
    tasks = [...tasks];
    final int Function(Task, Task) comparator = switch (_sort) {
      _SortMode.dueDate => (a, b) => a.dueDateTime.compareTo(b.dueDateTime),
      _SortMode.priority => (a, b) =>
          b.priority.index.compareTo(a.priority.index),
      _SortMode.created => (a, b) => b.createdAt.compareTo(a.createdAt),
    };
    tasks.sort(comparator);
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final t = NeonTokens.of(context);
    final tasks = _apply(taskProvider.tasks);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FadeSlideIn(
              child: GlassCard(
                radius: AppRadius.lg,
                padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 19, color: t.inkMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(fontSize: 13.5, color: t.ink),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          hintText: 'جست‌وجو در وظیفه‌ها…',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: t.inkFaint,
                          ),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GlassIconButton(
                        icon: Icons.close_rounded,
                        size: 34,
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    else
                      GlassIconButton(
                        icon: Icons.swap_vert_rounded,
                        size: 34,
                        tooltip: 'ترتیب',
                        color: NeonPalette.cyan,
                        onTap: _openSortSheet,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                NeonChip(
                  label: 'همه',
                  selected: _statusFilter == null,
                  color: NeonPalette.violet,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                for (final s in TaskStatus.values) ...[
                  const SizedBox(width: 8),
                  NeonChip(
                    label: s.label,
                    selected: _statusFilter == s,
                    color: s.color,
                    onTap: () => setState(() => _statusFilter = s),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                NeonChip(
                  label: 'همه دسته‌ها',
                  icon: Icons.folder_copy_outlined,
                  selected: _categoryFilter == null,
                  color: NeonPalette.cyan,
                  onTap: () => setState(() => _categoryFilter = null),
                ),
                for (final c in taskProvider.categories) ...[
                  const SizedBox(width: 8),
                  NeonChip(
                    label: c.name,
                    icon: c.iconData,
                    selected: _categoryFilter == c.id,
                    color: c.colorValue,
                    onTap: () => setState(() => _categoryFilter = c.id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${faNum(tasks.length)} وظیفه',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: t.inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  _sort.label,
                  style: TextStyle(fontSize: 11, color: t.inkFaint),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 40),
                      EmptyState(
                        icon: Icons.filter_alt_off_rounded,
                        message: 'وظیفه‌ای با این فیلترها پیدا نشد',
                        hint: 'فیلترها را عوض کن یا وظیفه‌ی تازه بساز',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 150),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FadeSlideIn(
                          delayMs: 40 * (i < 8 ? i : 8),
                          child: Dismissible(
                            key: ValueKey('task-${task.id}'),
                            direction: DismissDirection.endToStart,
                            background: _DeleteBackground(),
                            confirmDismiss: (_) => _confirmDelete(context),
                            onDismissed: (_) =>
                                context.read<TaskProvider>().deleteTask(task),
                            child: TaskCard(
                              task: task,
                              category:
                                  taskProvider.categoryById(task.categoryId),
                              onTap: () => Navigator.of(context).push(
                                neonRoute(TaskDetailScreen(taskId: task.id!)),
                              ),
                              onToggle: (_) =>
                                  taskProvider.toggleCompleted(task),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف وظیفه'),
        content: const Text('این وظیفه برای همیشه حذف می‌شود. مطمئنی؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'حذف',
              style: TextStyle(color: NeonPalette.rose),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
        child: GlassCard(
          radius: AppRadius.lg,
          blur: 26,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'ترتیب نمایش'),
              for (final m in _SortMode.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeonChip(
                    label: m.label,
                    selected: _sort == m,
                    color: NeonPalette.cyan,
                    onTap: () {
                      setState(() => _sort = m);
                      Navigator.pop(sheetCtx);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: NeonPalette.danger,
        boxShadow: [
          BoxShadow(
            color: NeonPalette.rose.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: -6,
          ),
        ],
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}
