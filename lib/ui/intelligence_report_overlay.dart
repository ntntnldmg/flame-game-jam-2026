import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../game/game_cubit.dart';
import '../models/intelligence_report.dart';

/// Full-screen overlay shown at the start of each new day.
/// Pauses gameplay and presents the day's intelligence briefing.
class IntelligenceReportOverlay extends StatelessWidget {
  final IntelligenceReport report;

  const IntelligenceReportOverlay({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withAlpha(230),
        child: Center(
          child: Container(
            width: 640,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.greenAccent, width: 2),
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
                        color: Colors.greenAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      'DAY ${report.day}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(height: 2, color: Colors.greenAccent),
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
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: const Text(
                      'CLASSIFIED',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Narrative
                Text(
                  report.narrativeText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
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
