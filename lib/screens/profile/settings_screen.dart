import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/category_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/neon/glass.dart';
import '../../widgets/neon/motion.dart';
import '../../widgets/neon/neon_button.dart';

const List<String> _paletteHex = [
  '#7C5CFF',
  '#22E3F5',
  '#FF4ECD',
  '#3DF5A5',
  '#FFB443',
  '#FF5C7A',
  '#5B8CFF',
];

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final auth = context.read<AuthProvider>();
    final t = NeonTokens.of(context);
    final myCategories =
        taskProvider.categories.where((c) => c.ownerId != null).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'تنظیمات', showBack: true),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
          children: [
            FadeSlideIn(
              child: GlassCard(
                radius: AppRadius.lg,
                glow: themeProvider.isDark
                    ? NeonPalette.violet
                    : NeonPalette.amber,
                glowOpacity: 0.18,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'ظاهر'),
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            color: (themeProvider.isDark
                                    ? NeonPalette.violet
                                    : NeonPalette.amber)
                                .withOpacity(0.15),
                            border: Border.all(
                              color: (themeProvider.isDark
                                      ? NeonPalette.violet
                                      : NeonPalette.amber)
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: Icon(
                            themeProvider.isDark
                                ? Icons.nightlight_round
                                : Icons.wb_sunny_rounded,
                            size: 18,
                            color: themeProvider.isDark
                                ? NeonPalette.violet
                                : NeonPalette.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                themeProvider.isDark
                                    ? 'حالت نئون شب'
                                    : 'حالت نئون روز',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: t.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'شیشه و نور، متناسب با چشم تو',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: t.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: themeProvider.isDark,
                          onChanged: themeProvider.setDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              delayMs: 80,
              child: GlassCard(
                radius: AppRadius.lg,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'دسته‌بندی‌های من',
                      color: NeonPalette.cyan,
                      trailingText: myCategories.isEmpty ? null : 'حذف با ✕',
                    ),
                    if (myCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'هنوز دسته‌بندی شخصی نساخته‌ای.',
                          style: TextStyle(fontSize: 12, color: t.inkMuted),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: myCategories
                            .map(
                              (c) => _CategoryPill(
                                category: c,
                                onDelete: () =>
                                    taskProvider.removeCategory(c),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    NeonOutlineButton(
                      label: 'افزودن دسته‌بندی',
                      icon: Icons.add_rounded,
                      onPressed: () => _showAddCategorySheet(
                        context,
                        auth.currentUser!.id!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              delayMs: 140,
              child: GlassCard(
                radius: AppRadius.lg,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'امنیت',
                      color: NeonPalette.magenta,
                    ),
                    NeonOutlineButton(
                      label: 'تغییر رمز عبور',
                      icon: Icons.lock_reset_rounded,
                      color: NeonPalette.magenta,
                      onPressed: () => _showChangePasswordDialog(
                        context,
                        auth.currentUser!.id!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              delayMs: 190,
              child: GlassCard(
                radius: AppRadius.lg,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: NeonPalette.brand,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تسکورا · نسخه‌ی آفلاین\nتمام داده‌ها فقط روی همین دستگاه ذخیره می‌شود.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.9,
                          color: t.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, int ownerId) {
    final ctrl = TextEditingController();
    String selectedHex = _paletteHex.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => GlassCard(
            radius: AppRadius.lg,
            blur: 26,
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'دسته‌بندی جدید'),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'نام دسته‌بندی',
                    prefixIcon: Icon(Icons.folder_open_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _paletteHex.map((hex) {
                    final color = Color(
                      int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
                    );
                    final selected = selectedHex == hex;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedHex = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(selected ? 0.7 : 0.25),
                              blurRadius: selected ? 18 : 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                NeonButton(
                  label: 'افزودن',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    final name = ctrl.text.trim();
                    if (name.isEmpty) return;
                    context.read<TaskProvider>().addCategory(
                          TaskCategory(
                            name: name,
                            color: selectedHex,
                            ownerId: ownerId,
                          ),
                        );
                    Navigator.pop(sheetCtx);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, int userId) {
    final ctrl = TextEditingController();
    String? error;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('تغییر رمز عبور'),
          content: TextField(
            controller: ctrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'رمز عبور جدید',
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await AuthService().changePassword(userId, ctrl.text);
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                } catch (e) {
                  setDialogState(() => error =
                      e.toString().replaceFirst('Exception: ', '').trim());
                }
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final TaskCategory category;
  final VoidCallback onDelete;

  const _CategoryPill({required this.category, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = category.colorValue;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.iconData, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 15, color: color),
          ),
        ],
      ),
    );
  }
}
