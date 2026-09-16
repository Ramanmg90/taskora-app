import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../services/jalali_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final t = NeonTokens.of(context);
    final matches = taskProvider.tasks.where((x) => x.id == taskId);
    final task = matches.isEmpty ? null : matches.first;

    if (task == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const GlassAppBar(title: 'جزئیات وظیفه', showBack: true),
        body: const Center(child: Text('این وظیفه حذف شده است')),
      );
    }

    final category = taskProvider.categoryById(task.categoryId);
    final completed = task.status == TaskStatus.completed;
    final jDue = Jalali.fromDateTime(task.dueDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'جزئیات وظیفه',
        showBack: true,
        actions: [
          GlassIconButton(
            icon: Icons.edit_outlined,
            tooltip: 'ویرایش',
            onTap: () => Navigator.of(context).push(
              neonRoute(TaskFormScreen(existingTask: task)),
            ),
          ),
          const SizedBox(width: 6),
          GlassIconButton(
            icon: Icons.delete_outline_rounded,
            color: NeonPalette.rose,
            tooltip: 'حذف',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('حذف وظیفه'),
                  content: const Text('آیا از حذف این وظیفه مطمئن هستید؟'),
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
              if (confirm == true) {
                await taskProvider.deleteTask(task);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
          children: [
            FadeSlideIn(
              child: GlassCard(
                radius: AppRadius.lg,
                glow: task.isOverdue ? NeonPalette.rose : task.priority.color,
                glowOpacity: 0.22,
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.5,
                        color: t.ink,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        PriorityBadge(priority: task.priority),
                        StatusBadge(
                          status: task.status,
                          isOverdue: task.isOverdue,
                        ),
                        if (category != null)
                          NeonTag(
                            label: category.name,
                            color: category.colorValue,
                            icon: category.iconData,
                          ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.white.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: t.glassBorder),
                        ),
                        child: Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.9,
                            color: t.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              delayMs: 90,
              child: GlassCard(
                radius: AppRadius.lg,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'زمان‌بندی'),
                    _InfoRow(
                      icon: Icons.event_rounded,
                      color: NeonPalette.cyan,
                      label: 'تاریخ انجام',
                      value:
                          '${faNum(jDue.day)} ${jDue.monthName} ${faNum(jDue.year)}',
                    ),
                    if (task.dueTime != null)
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        color: NeonPalette.magenta,
                        label: 'ساعت',
                        value: faTime(
                          task.dueTime!.hour,
                          task.dueTime!.minute,
                        ),
                      ),
                    if (task.reminderOffsets.isNotEmpty)
                      _InfoRow(
                        icon: Icons.notifications_active_rounded,
                        color: NeonPalette.amber,
                        label: 'یادآوری‌ها',
                        value: task.reminderOffsets
                            .map(reminderOffsetLabel)
                            .join('، '),
                      ),
                    _InfoRow(
                      icon: Icons.add_circle_outline_rounded,
                      color: NeonPalette.violet,
                      label: 'ایجاد شده',
                      value: () {
                        final j = Jalali.fromDateTime(task.createdAt);
                        return '${faNum(j.day)} ${j.monthName} ${faNum(j.year)}';
                      }(),
                    ),
                    if (task.completedAt != null)
                      _InfoRow(
                        icon: Icons.verified_rounded,
                        color: NeonPalette.lime,
                        label: 'تکمیل شده',
                        value: () {
                          final j = Jalali.fromDateTime(task.completedAt!);
                          return '${faNum(j.day)} ${j.monthName} ${faNum(j.year)}';
                        }(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            FadeSlideIn(
              delayMs: 140,
              child: completed
                  ? NeonOutlineButton(
                      label: 'برگرداندن به در انتظار',
                      icon: Icons.replay_rounded,
                      color: NeonPalette.amber,
                      onPressed: () => taskProvider.toggleCompleted(task),
                    )
                  : NeonButton(
                      label: 'شروع کار روی وظیفه',
                      icon: Icons.play_arrow_rounded,
                      gradient: NeonPalette.cta,
                      glowColor: NeonPalette.orange,
                      onPressed: () => taskProvider.toggleCompleted(task),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withOpacity(0.32)),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10.5, color: t.inkFaint),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: t.ink,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
