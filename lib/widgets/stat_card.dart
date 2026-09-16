import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/fa_num.dart';
import 'neon/glass.dart';

/// کارت آمار شیشه‌ای با عدد شمارنده و آیکون نئونی
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = NeonTokens.of(context);
    return GlassCard(
      onTap: onTap,
      glow: color,
      glowOpacity: 0.30,
      blur: 8,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: Border.all(color: color.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.28),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '${faNum(v.round())}$suffix',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: t.ink,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: t.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
