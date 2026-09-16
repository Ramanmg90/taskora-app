import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ─────────────────────────────────────────────────────────────
///  Taskora · Neon Glassmorphism Design System
///  همه‌ی رنگ‌ها، گرادیان‌ها، شعاع‌ها و گلوها از اینجا می‌آیند.
/// ─────────────────────────────────────────────────────────────

class NeonPalette {
  // رنگ‌های برند — برگرفته از طراحی جدید (کارت‌های خانه/وظایف/پروژه‌ها)
  static const Color teal = Color(0xFF2DD4BF); // اصلی (تمرکز/تکمیل)
  static const Color cyan = Color(0xFF29B6F6); // پروژه‌ها/فعال
  static const Color violet = Color(0xFF8B7CF6); // یادآوری‌ها/روز متوالی
  static const Color indigo = Color(0xFF5B8CFF);
  static const Color magenta = Color(0xFFFF4ECD);
  static const Color lime = Color(0xFF34D399); // موفقیت/تکمیل‌شده
  static const Color amber = Color(0xFFFFB443);
  static const Color orange = Color(0xFFFF8A3D); // CTA اصلی
  static const Color rose = Color(0xFFFF5C6C); // خطر/انجام‌شده/حذف

  // پس‌زمینه‌های تیره — نزدیک به سیاهِ طرح جدید
  static const Color abyss = Color(0xFF060809);
  static const Color deep = Color(0xFF0B0F12);
  static const Color night = Color(0xFF12171B);

  // پس‌زمینه‌های روشن
  static const Color mist = Color(0xFFF2F1FF);
  static const Color cloud = Color(0xFFE9E8FF);

  static const Color inkDark = Color(0xFFEDEFF2);
  static const Color inkLight = Color(0xFF15173A);

  /// گرادیان اصلی برند (بنر خوش‌آمدگویی داشبورد: فیروزه‌ای → آبی)
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [teal, cyan],
  );

  /// گرادیان دکمه‌ی اصلی CTA («شروع کار روی وظیفه»)
  static const LinearGradient cta = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [amber, orange],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [lime, teal],
  );

  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [rose, magenta],
  );
}

/// توکن‌های وابسته به تم (تیره / روشن)
class NeonTokens {
  final bool isDark;
  const NeonTokens(this.isDark);

  static NeonTokens of(BuildContext context) =>
      NeonTokens(Theme.of(context).brightness == Brightness.dark);

  Color get ink => isDark ? NeonPalette.inkDark : NeonPalette.inkLight;
  Color get inkMuted => isDark
      ? const Color(0xFF9AA0C8)
      : const Color(0xFF6A6F99);
  Color get inkFaint => isDark
      ? const Color(0xFF6F76A6)
      : const Color(0xFF9195BC);

  /// رنگ پایه شیشه
  Color get glassTop => isDark
      ? Colors.white.withOpacity(0.10)
      : Colors.white.withOpacity(0.70);
  Color get glassBottom => isDark
      ? Colors.white.withOpacity(0.03)
      : Colors.white.withOpacity(0.38);
  Color get glassBorder => isDark
      ? Colors.white.withOpacity(0.14)
      : Colors.white.withOpacity(0.85);
  Color get glassStroke => isDark
      ? Colors.white.withOpacity(0.06)
      : const Color(0xFF7C5CFF).withOpacity(0.10);

  Color get fieldFill => isDark
      ? Colors.white.withOpacity(0.05)
      : Colors.white.withOpacity(0.62);

  List<BoxShadow> glow(Color color, {double opacity = 0.35, double blur = 28, double spread = -6}) => [
        BoxShadow(
          color: color.withOpacity(isDark ? opacity : opacity * 0.55),
          blurRadius: blur,
          spreadRadius: spread,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.45)
              : const Color(0xFF6A5CFF).withOpacity(0.12),
          blurRadius: 26,
          spreadRadius: -8,
          offset: const Offset(0, 12),
        ),
      ];
}

class AppRadius {
  static const double xs = 10;
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 26;
  static const double xl = 34;
  static const double pill = 999;
}

class AppTheme {
  static const Color primary = NeonPalette.teal;
  static const Color primaryDark = NeonPalette.cyan;

  /// اگر فونت وزیرمتن را به assets اضافه کنید، خودکار استفاده می‌شود.
  static const String? fontFamily = 'Vazirmatn';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final t = NeonTokens(isDark);
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final scheme = base.colorScheme.copyWith(
      primary: NeonPalette.teal,
      secondary: NeonPalette.cyan,
      tertiary: NeonPalette.orange,
      error: NeonPalette.rose,
      surface: isDark ? NeonPalette.night : Colors.white,
      onSurface: t.ink,
    );

    final textTheme = base.textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: t.ink,
      displayColor: t.ink,
    );

    return base.copyWith(
      colorScheme: scheme,
      brightness: brightness,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // پس‌زمینه شفاف است؛ لایه‌ی Aurora زیر همه چیز کشیده می‌شود.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      splashFactory: InkRipple.splashFactory,
      highlightColor: NeonPalette.teal.withOpacity(0.06),
      splashColor: NeonPalette.teal.withOpacity(0.10),
      dividerTheme: DividerThemeData(
        color: t.glassBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: t.ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? NeonPalette.night.withOpacity(0.92)
            : Colors.white.withOpacity(0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: t.glassBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? NeonPalette.night.withOpacity(0.96)
            : NeonPalette.inkLight.withOpacity(0.94),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonPalette.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeonPalette.cyan,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          side: BorderSide(color: t.glassBorder),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.fieldFill,
        hintStyle: TextStyle(color: t.inkFaint, fontSize: 13),
        labelStyle: TextStyle(color: t.inkMuted, fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: NeonPalette.teal,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: t.inkMuted,
        suffixIconColor: t.inkMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: t.glassBorder, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: t.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: NeonPalette.teal, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: NeonPalette.rose, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: NeonPalette.rose, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : t.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NeonPalette.teal
              : (isDark ? Colors.white10 : Colors.black12),
        ),
        trackOutlineColor:
            WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? NeonPalette.lime
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(NeonPalette.abyss),
        side: BorderSide(color: t.inkFaint, width: 1.4),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: NeonPalette.cyan,
        linearTrackColor: Colors.white12,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: t.inkMuted,
        textColor: t.ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: NeonPalette.night.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
