import 'package:bigbrother/app_typography.dart';
import 'package:bigbrother/consts.dart';
import 'package:flutter/material.dart';

import '../game/game_state.dart';
import 'day_counter_widget.dart';

class TopStatusHud extends StatelessWidget {
  final GameState state;

  const TopStatusHud({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final dayProgress =
        1.0 - (state.remainingTimeInDay / Consts.dayDuration).clamp(0.0, 1.0);
    final ongoingArrests = state.todayResidents
        .where((r) => r.isArrestPending)
        .length;
    final pendingInvestigations = state.todayResidents
        .where((r) => r.isInvestigationPending)
        .length;
    final installedWireTaps = state.todayResidents
        .where((r) => r.hasWireTap)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 920;
        final veryCompact = constraints.maxWidth < 700;
        final dayCounterSize = veryCompact ? 92.0 : (compact ? 112.0 : 142.0);

        final labelStyle = AppTypography.mono(
          color: AppColors.bluishWhite,
          fontSize: veryCompact ? 14 : (compact ? 16 : 21),
          fontWeight: FontWeight.w400,
          letterSpacing: 0.6,
          height: 1.15,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  veryCompact ? 10 : 14,
                  12,
                  veryCompact ? 10 : 14,
                  12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.green, width: 2),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x730C4D66),
                      Color(0x2A0B1E2B),
                      Color(0x12050F16),
                    ],
                    stops: [0.0, 0.42, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'STATUS',
                          style: AppTypography.mono(
                            color: AppColors.green,
                            fontSize: veryCompact ? 30 : (compact ? 36 : 45),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.5,
                            height: 0.95,
                          ),
                        ),
                        const Spacer(),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: state.terroristThreat),
                          duration: const Duration(
                            milliseconds: Consts.threatDisplayAnimationMs,
                          ),
                          curve: Curves.easeInOut,
                          builder: (context, animatedThreat, child) {
                            return Text(
                              'Terrorist Threat: ${animatedThreat.toStringAsFixed(1)} %',
                              style: AppTypography.mono(
                                color: AppColors.red,
                                fontSize: veryCompact
                                    ? 17
                                    : (compact ? 21 : 27),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.0,
                                height: 1.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: veryCompact ? 8 : 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ongoing arrests: $ongoingArrests',
                                style: labelStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Pending investigations: $pendingInvestigations',
                                style: labelStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Installed wire taps: $installedWireTaps',
                                style: labelStyle,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: veryCompact ? 8 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining arrest capacity: ${state.remainingArrestsToday}',
                                style: labelStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Remaining investigation capacity: ${state.remainingInvestigationsToday}',
                                style: labelStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Available wire taps: ${state.remainingWireTapsToday}',
                                style: labelStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: veryCompact ? 10 : 24),
            DayCounterWidget(
              day: state.currentDay,
              dayProgress: dayProgress,
              size: dayCounterSize,
            ),
          ],
        );
      },
    );
  }
}
