import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../consts.dart';
import '../game/game_cubit.dart';
import '../models/intelligence_report.dart';

/// Full-screen overlay shown at the start of each new day.
/// Pauses gameplay and presents the day's intelligence briefing.
class IntelligenceReportOverlay extends StatelessWidget {
  final IntelligenceReport report;

  const IntelligenceReportOverlay({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final categoryLabel = switch (report.focusCategory) {
      'ageGroup' => 'AGE GROUP',
      'occupation' => 'OCCUPATION',
      'religion' => 'RELIGION',
      'ethnicity' => 'ETHNICITY',
      _ => report.focusCategory.toUpperCase(),
    };

    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Text(
                  'CLASSIFIED // EYES ONLY',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
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

              // Flagged group
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  color: const Color(0xFF0A1A0A),
                ),
                child: Row(
                  children: [
                    const Text(
                      'FLAGGED GROUP  ',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '$categoryLabel: ',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      report.focusValue.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Modifier warning
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${Consts.intelligenceRiskModifier.toInt()} RISK MODIFIER applied to matching citizens this cycle.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Continue button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<GameCubit>().acknowledgeReport(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    );
  }
}
