import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/fa_num.dart';
import '../../widgets/task_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../tasks/task_detail_screen.dart';
import '../profile/settings_screen.dart';
import '../../services/jalali_helper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final auth = context.watch<AuthProvider>();
    final t = NeonTokens.of(context);
    final today = Jalali.now();
    final user = auth.currentUser;
    final name = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : (user?.username ?? '');

    final stats = taskProvider.stats;
    final completed = stats['completed'] ?? 0;

    final todayTasks = taskProvider.todayTasks;
    final todayDone = taskProvider.tasks.where((x) {
      final d = x.dueDate;
      final n = DateTime.now();
      return x.status == TaskStatus.completed &&
          d.year == n.year &&
          d.month == n.month &&
          d.day == n.day;
    }).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: NeonPalette.cyan,
        backgroundColor: t.isDark ? NeonPalette.night : Colors.white,
        onRefresh: () async {
          if (auth.currentUser != null) {
            await context.read<TaskProvider>().load(auth.currentUser!.id!);
          }
        },
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 14,
            16,
            150,
          ),
          children: [
            FadeSlideIn(
              child: _GreetingBanner(
                name: name,
                dateLabel:
                    '${jalaliWeekdayNames[today.weekday]}، ${faNum(today.day)} ${today.monthName} ${faNum(today.year)}',
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delayMs: 100,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.62,
                children: [
                  StatCard(
                    label: 'تمرکز امروز',
                    value: (todayDone * 25),
                    suffix: ' د',
                    icon: Icons.bolt_rounded,
                    color: NeonPalette.teal,
                  ),
                  StatCard(
                    label: 'پروژه‌های فعال',
                    value: stats['pending'] ?? 0,
                    icon: Icons.folder_copy_rounded,
                    color: NeonPalette.cyan,
                  ),
                  StatCard(
                    label: 'انجام‌شده',
                    value: completed,
                    icon: Icons.check_circle_rounded,
                    color: NeonPalette.orange,
                  ),
                  StatCard(
                    label: 'روز متوالی',
                    value: stats['overdue'] ?? 0,
                    icon: Icons.local_fire_department_rounded,
                    color: NeonPalette.violet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            _Section(
              title: 'وظایف امروز',
              color: NeonPalette.cyan,
              tasks: todayTasks,
              emptyMessage: 'برای امروز چیزی ثبت نشده',
              emptyHint: 'با دکمه‌ی + یک وظیفه بساز',
              emptyIcon: Icons.today_rounded,
            ),
            _Section(
              title: 'عقب‌افتاده‌ها',
              color: NeonPalette.rose,
              tasks: taskProvider.overdueTasks,
              emptyMessage: 'هیچ کار عقب‌افتاده‌ای نداری 🎉',
              emptyIcon: Icons.shield_moon_rounded,
            ),
            _Section(
              title: 'در راه',
              color: NeonPalette.violet,
              tasks: taskProvider.upcomingTasks,
              emptyMessage: 'افق کاری‌ات خالی است',
              emptyIcon: Icons.rocket_launch_rounded,
            ),
            _Section(
              title: 'تازه تمام‌شده‌ها',
              color: NeonPalette.lime,
              tasks: taskProvider.completedTasks,
              emptyMessage: 'هنوز وظیفه‌ای تکمیل نکرده‌ای',
              emptyIcon: Icons.emoji_events_rounded,
            ),
            FadeSlideIn(
              delayMs: 160,
              child: const _TipCard(
                title: 'نکته‌ی بهره‌وری',
                message:
                    'تمرکز بدون وقفه‌ی ۹۰ دقیقه‌ای معادل ۴ ساعت کار پراکنده است. برای شروع از تایمر استفاده کن.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بنر خوش‌آمدگویی گرادیانی بالای داشبورد
class _GreetingBanner extends StatelessWidget {
  final String name;
  final String dateLabel;

  const _GreetingBanner({required this.name, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: NeonPalette.brand,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: NeonPalette.teal.withOpacity(0.35),
            blurRadius: 26,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام ${name.isNotEmpty ? name : ''} عزیز',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).push(neonRoute(const SettingsScreen())),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 17),
            ),
          ),
        ],
      ),
    );
  }
}

/// کارت نکته‌ی پایانی داشبورد — بنر گرادیانی مثل طرح مرجع
class _TipCard extends StatelessWidget {
  final String title;
  final String message;
  const _TipCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: NeonPalette.brand,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: NeonPalette.cyan.withOpacity(0.30),
            blurRadius: 24,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              height: 1.8,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final String emptyMessage;
  final String? emptyHint;
  final IconData emptyIcon;
  final Color color;

  const _Section({
    required this.title,
    required this.tasks,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.color,
    this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            color: color,
            trailingText: tasks.isEmpty ? null : '${faNum(tasks.length)} مورد',
          ),
          if (tasks.isEmpty)
            EmptyState(
              icon: emptyIcon,
              message: emptyMessage,
              hint: emptyHint,
              color: color,
            )
          else
            ...List.generate(tasks.length, (i) {
              final task = tasks[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FadeSlideIn(
                  delayMs: 60 * (i < 6 ? i : 6),
                  child: TaskCard(
                    task: task,
                    category: taskProvider.categoryById(task.categoryId),
                    onTap: () => Navigator.of(context).push(
                      neonRoute(TaskDetailScreen(taskId: task.id!)),
                    ),
                    onToggle: (_) => taskProvider.toggleCompleted(task),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
