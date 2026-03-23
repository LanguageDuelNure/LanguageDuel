// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class GridBackground extends StatelessWidget {
  final AlignmentGeometry glowAlignment;
  final double glowRadius;
  final Color? glowColor;

  const GridBackground({
    super.key,
    this.glowAlignment = Alignment.center,
    this.glowRadius = 0.8,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        glowAlignment: glowAlignment,
        glowRadius: glowRadius,
        glowColor: glowColor ?? AppTheme.accent,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final AlignmentGeometry glowAlignment;
  final double glowRadius;
  final Color glowColor;

  const _GridPainter({
    required this.glowAlignment,
    required this.glowRadius,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withOpacity(0.4)
      ..strokeWidth = 0.5;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final gradient = RadialGradient(
      center: glowAlignment as Alignment,
      radius: glowRadius,
      colors: [glowColor.withOpacity(0.05), Colors.transparent],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader =
            gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}