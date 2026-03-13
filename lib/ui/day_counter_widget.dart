import 'dart:math' as math;

import 'package:bigbrother/app_typography.dart';
import 'package:bigbrother/consts.dart';
import 'package:flutter/material.dart';

/// A circular day counter with crosshair tick marks and a sweeping progress arc
/// that fills clockwise as the current day advances.
class DayCounterWidget extends StatelessWidget {
  final int day;

  /// 0.0 = start of day, 1.0 = end of day.
  final double dayProgress;

  final double size;

  const DayCounterWidget({
    super.key,
    required this.day,
    required this.dayProgress,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DayCounterPainter(
          dayProgress: dayProgress.clamp(0.0, 1.0),
          size: size,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DAY',
                style: AppTypography.mono(
                  color: AppColors.bluishWhite,
                  fontSize: size * 0.13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  height: 1.0,
                ),
              ),
              Text(
                '$day',
                style: AppTypography.mono(
                  color: AppColors.bluishWhite,
                  fontSize: size * 0.23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCounterPainter extends CustomPainter {
  final double dayProgress;
  final double size;

  _DayCounterPainter({required this.dayProgress, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = canvasSize.width * 0.37;
    final strokeWidth = canvasSize.width * 0.04;

    const fillColor = AppColors.circleFill;
    const baseRingColor = AppColors.green;
    const progressColor = AppColors.bluishWhite;
    const tickColor = AppColors.bluishWhite;

    // 1. Filled background circle.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // 2. Dim base ring — always full circle, gives depth.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = baseRingColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // 3. Progress arc — sweeps clockwise from 12 o'clock.
    if (dayProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // 12 o'clock
        dayProgress * 2 * math.pi,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
    }

    // 4. Crosshair tick marks crossing the ring at cardinal points.
    //    Each tick starts slightly inside the circle and ends outside.
    final tickInside = strokeWidth * 1.2; // how far inside the ring
    final tickOutside = strokeWidth * 1.8; // how far outside the ring
    final tickInnerR = radius - tickInside;
    final tickOuterR = radius + tickOutside;

    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.butt;

    for (final angle in [
      -math.pi / 2, // top
      0.0, // right
      math.pi / 2, // bottom
      math.pi, // left
    ]) {
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        Offset(center.dx + cos * tickInnerR, center.dy + sin * tickInnerR),
        Offset(center.dx + cos * tickOuterR, center.dy + sin * tickOuterR),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DayCounterPainter oldDelegate) =>
      oldDelegate.dayProgress != dayProgress;
}
