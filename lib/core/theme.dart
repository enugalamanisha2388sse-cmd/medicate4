import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class AppTheme {
  static bool _isDark = false; // default to light healthcare theme

  static bool get isDark => _isDark;

  static void updateThemeMode(bool isDark) {
    _isDark = isDark;
  }

  // Dynamic getters based on active ThemeMode
  static Color get background => _isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC);
  static Color get cardColor => _isDark ? Color(0xFF1E293B) : Color(0xFFFFFFFF);
  static Color get primaryTeal => _isDark ? Color(0xFF3B82F6) : Color(0xFF2563EB); // mapped to primary blue
  static Color get primaryCyan => Color(0xFF0EA5E9); // mapped to info sky blue
  static Color get primaryIndigo => Color(0xFF4F46E5);
  static Color get primaryPurple => Color(0xFF8B5CF6);
  static Color get textPrimary => _isDark ? Color(0xFFFFFFFF) : Color(0xFF000000);
  static Color get textSecondary => _isDark ? Color(0xFF94A3B8) : Color(0xFF64748B);
  static Color get borderCard => _isDark ? Color(0xFF334155) : Color(0xFFE2E8F0);

  // Exact theme colors requested
  static Color get primaryBlue => _isDark ? Color(0xFF3B82F6) : Color(0xFF2563EB);
  static Color get primaryDarkBlue => Color(0xFF1D4ED8);
  static Color get lightBlue => Color(0xFFDBEAFE);
  static Color get mainBackground => _isDark ? Color(0xFF0F172A) : Color(0xFFF8FAFC);
  static Color get cardBackground => _isDark ? Color(0xFF1E293B) : Color(0xFFFFFFFF);
  static Color get secondaryBackground => _isDark ? Color(0xFF1E293B) : Color(0xFFEFF6FF);

  static Color get success => Color(0xFF22C55E);
  static Color get warning => Color(0xFFF59E0B);
  static Color get error => Color(0xFFEF4444);
  static Color get info => Color(0xFF0EA5E9);
  static Color get textHint => Color(0xFF94A3B8);
  static Color get border => _isDark ? Color(0xFF334155) : Color(0xFFE2E8F0);
  static Color get divider => Color(0xFFCBD5E1);

  // Gradients
  static LinearGradient get tealCyanGradient => LinearGradient(
    colors: [primaryTeal, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get indigoPurpleGradient => LinearGradient(
    colors: [primaryIndigo, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get darkCardGradient => LinearGradient(
    colors: _isDark 
      ? [Color(0xFF1E293B), Color(0xFF0F172A)]
      : [Color(0xFFFFFFFF), Color(0xFFEFF6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Material 3 themes configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Color(0xFF2563EB),
      scaffoldBackgroundColor: Color(0xFFF8FAFC),
      cardColor: Color(0xFFFFFFFF),
      dividerColor: Color(0xFFCBD5E1),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: Color(0xFF1E293B)),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: Color(0xFF64748B)),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF2563EB),
        brightness: Brightness.light,
        background: Color(0xFFF8FAFC),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Color(0xFF3B82F6),
      scaffoldBackgroundColor: Color(0xFF0F172A),
      cardColor: Color(0xFF1E293B),
      dividerColor: Color(0xFF334155),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Poppins', color: Color(0xFFF8FAFC)),
        bodyMedium: TextStyle(fontFamily: 'Poppins', color: Color(0xFF94A3B8)),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF3B82F6),
        brightness: Brightness.dark,
        background: Color(0xFF0F172A),
      ),
    );
  }

  // Card Decoration with optional Glassmorphic effect
  static BoxDecoration glassDecoration({
    double radius = 16.0,
    Color borderColor = const Color(0x33FFFFFF),
    Color fillColor = const Color(0x0DFFFFFF),
  }) {
    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}

// Glassmorphic Card Container Widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final Color borderColor;
  final Color fillColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  GlassCard({
    super.key,
    required this.child,
    this.radius = 20.0,
    this.blur = 15.0,
    this.borderColor = const Color(0x1AFFFFFF),
    this.fillColor = const Color(0x14FFFFFF),
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark;
    final resolvedFillColor = fillColor == const Color(0x14FFFFFF)
        ? (isDark ? const Color(0x14FFFFFF) : const Color(0xB3FFFFFF))
        : fillColor;
    final resolvedBorderColor = borderColor == const Color(0x1AFFFFFF)
        ? (isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000))
        : borderColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: resolvedFillColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: resolvedBorderColor, width: 1.2),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// Custom Fade & Slide transition for high animatic feel
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideOffset;
  final Curve curve;

  FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = 40.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 1.0, curve: widget.curve)),
    );

    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 1.0, curve: widget.curve)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ----------------------------------------------------
// MOBILE PREVIEW FRAME wrapper for wide displays
// ----------------------------------------------------
class MobileViewFrame extends StatelessWidget {
  final Widget child;
  MobileViewFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 480) {
      return child;
    }

    return Scaffold(
      backgroundColor: Color(0xFF06090E),
      body: Center(
        child: Container(
          width: 430,
          margin: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: Color(0xFF1E293B), width: 10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryCyan.withOpacity(0.2),
                blurRadius: 36,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// DYNAMIC ANIMATED NEON PARTICLE BACKGROUND
// ----------------------------------------------------
class StarNode {
  double x;
  double y;
  double size;
  double speed;
  StarNode({required this.x, required this.y, required this.size, required this.speed});
}

class NeonBlobPainter extends CustomPainter {
  final double progress;
  NeonBlobPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppTheme.primaryTeal.withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);

    final paint2 = Paint()
      ..color = AppTheme.primaryIndigo.withOpacity(0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 65);

    final paint3 = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 75);

    final double x1 = size.width * 0.2 + 50 * sin(progress * 2 * pi);
    final double y1 = size.height * 0.3 + 60 * cos(progress * 2 * pi);

    final double x2 = size.width * 0.8 + 60 * cos(progress * 2 * pi + 1);
    final double y2 = size.height * 0.7 + 50 * sin(progress * 2 * pi + 1);

    final double x3 = size.width * 0.5 + 40 * sin(progress * 2 * pi + 2);
    final double y3 = size.height * 0.5 + 40 * cos(progress * 2 * pi + 2);

    canvas.drawCircle(Offset(x1, y1), 110, paint1);
    canvas.drawCircle(Offset(x2, y2), 130, paint2);
    canvas.drawCircle(Offset(x3, y3), 90, paint3);
  }

  @override
  bool shouldRepaint(covariant NeonBlobPainter oldDelegate) => oldDelegate.progress != progress;
}

class ParticleGridPainter extends CustomPainter {
  final double progress;
  final List<StarNode> stars;

  ParticleGridPainter(this.progress, this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.12);
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;

    // Drifting coordinates
    for (var star in stars) {
      double currentY = star.y - (progress * size.height * star.speed);
      while (currentY < 0) {
        currentY += size.height;
      }
      final double currentX = (star.x + 12 * sin(progress * 2 * pi + star.y)) % size.width;
      canvas.drawCircle(Offset(currentX, currentY), star.size, dotPaint);
    }

    // Connect subtle lines
    const double step = 64.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double j = 0; j < size.height; j += step) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DynamicBackground extends StatefulWidget {
  final Widget child;
  DynamicBackground({super.key, required this.child});

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<StarNode> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 24),
    )..repeat();

    final random = Random();
    _stars = List.generate(24, (index) {
      return StarNode(
        x: random.nextDouble() * 450,
        y: random.nextDouble() * 900,
        size: 0.8 + random.nextDouble() * 1.8,
        speed: 0.08 + random.nextDouble() * 0.15,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: NeonBlobPainter(_controller.value),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: ParticleGridPainter(_controller.value, _stars),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}
