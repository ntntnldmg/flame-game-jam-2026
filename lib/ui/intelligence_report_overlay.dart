import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../consts.dart';
import '../game/game_cubit.dart';
import '../models/intelligence_report.dart';

/// Full-screen overlay shown at the start of each new day.
/// Pauses gameplay and presents the day's intelligence briefing.
class IntelligenceReportOverlay extends StatefulWidget {
  final IntelligenceReport report;

  const IntelligenceReportOverlay({super.key, required this.report});

  @override
  State<IntelligenceReportOverlay> createState() =>
      _IntelligenceReportOverlayState();
}

class _IntelligenceReportOverlayState extends State<IntelligenceReportOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final textLength = widget.report.narrativeText.length;
    final ms = (textLength * 18).clamp(1400, 11000).toInt();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: AppColors.reportOverlayScrimAlt,
        child: Center(
          child: Container(
            width: 640,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.black,
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'INTELLIGENCE BRIEFING',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      'DAY ${widget.report.day}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(height: 2, color: AppColors.green),
                const SizedBox(height: 24),

                // Classification stamp
                Transform.rotate(
                  angle: -0.15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.red),
                    ),
                    child: const Text(
                      'CLASSIFIED',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Narrative
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final visibleChars =
                        (widget.report.narrativeText.length * _controller.value)
                            .floor();
                    final visibleText = widget.report.narrativeText.substring(
                      0,
                      visibleChars,
                    );
                    return Text(
                      visibleText,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Continue button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<GameCubit>().acknowledgeReport(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text(
                        'CONTINUE MONITORING',
                        style: TextStyle(fontSize: 16, letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
