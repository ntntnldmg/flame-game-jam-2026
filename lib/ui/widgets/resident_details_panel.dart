import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_typography.dart';
import '../../consts.dart';
import '../../game/game_cubit.dart';
import '../../game/game_state.dart';
import '../../models/resident.dart';

class ResidentDetailsPanel extends StatelessWidget {
  final Resident resident;
  final GameState state;
  final VoidCallback onBack;

  const ResidentDetailsPanel({
    super.key,
    required this.resident,
    required this.state,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final residentStatus = _residentStatusText(resident);
    final effectiveRisk = resident.effectiveRiskScore(state.currentReport);

    final canOrderInvestigation =
        !resident.isInvestigated &&
        !resident.isInvestigationPending &&
        !resident.isArrested &&
        state.remainingInvestigationsToday > 0;
    final canInstallWireTap =
        !resident.hasWireTap && state.remainingWireTapsToday > 0;
    final canIssueArrest =
        !resident.isArrested &&
        !resident.isArrestPending &&
        state.remainingArrestsToday > 0;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.green, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.green.withAlpha(180),
                  size: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      resident.id,
                      style: AppTypography.barcode39(
                        color: AppColors.green.withAlpha(180),
                        fontSize: 80,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.mono(
                        color: AppColors.green.withAlpha(180),
                        fontSize: 20,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(text: 'STATUS:  '),
                        TextSpan(text: residentStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  _DetailLine(label: 'FIRST NAME', value: resident.firstName),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'LAST NAME', value: resident.lastName),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'SEX', value: resident.sex.toLowerCase()),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'AGE', value: '${resident.age}'),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'ADDRESS', value: resident.street),
                  Padding(
                    padding: const EdgeInsets.only(left: 110),
                    child: Text(
                      resident.district,
                      style: TextStyle(
                        color: AppColors.bluishWhite,
                        fontSize: 14,
                        letterSpacing: 0.6,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'PHONE', value: resident.phoneNumber),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'OCCUPATION', value: resident.occupation),
                  const SizedBox(height: 18),
                  if (resident.isInvestigated)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'ESTIMATED RISK: ${_residentRiskText(effectiveRisk)}',
                        style: AppTypography.mono(
                          color: effectiveRisk > Consts.arrestGoodThreshold
                              ? AppColors.red
                              : AppColors.bluishWhite,
                          fontSize: 16,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (resident.hasWireTap)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'WIRE TAP INSTALLED',
                        style: AppTypography.mono(
                          color: AppColors.green,
                          fontSize: 15,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResidentActionButton(
                label: 'ORDER INVESTIGATION',
                enabled: canOrderInvestigation,
                onTap: canOrderInvestigation
                    ? () => cubit.orderInvestigation(resident)
                    : null,
              ),
              _ResidentActionButton(
                label: 'INSTALL WIRE TAP',
                enabled: canInstallWireTap,
                onTap: canInstallWireTap
                    ? () => cubit.installWireTap(resident)
                    : null,
              ),
              _ResidentActionButton(
                label: 'ISSUE ARREST WARRANT',
                enabled: canIssueArrest,
                onTap: canIssueArrest
                    ? () => cubit.issueArrestWarrant(resident)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _residentStatusText(Resident resident) {
    if (resident.isArrested) return 'DETAINED';
    if (resident.isArrestPending) return 'WARRANT ISSUED';
    if (resident.isInvestigationPending) return 'PENDING INVESTIGATION';
    if (resident.hasWireTap) return 'MONITORED';
    return 'NORMAL';
  }
  
  String _residentRiskText(double risk) {
  	if (risk >= 0.0 && risk < 25.0) {
  		return 'low';
  	} else if (risk >= 25.0 && risk < 50.0) {
  		return 'medium';
  	} else if (risk >= 50.0 && risk < 75.0) {
  		return 'high';
  	} else {
  		return 'critical – arrest immediately';
  	}
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: AppTypography.mono(
              color: AppColors.green.withAlpha(190),
              fontSize: 16,
              letterSpacing: 0.7,
              height: 1.35,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.mono(
              color: AppColors.bluishWhite,
              fontSize: 16,
              letterSpacing: 0.6,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResidentActionButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _ResidentActionButton({
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  State<_ResidentActionButton> createState() => _ResidentActionButtonState();
}

class _ResidentActionButtonState extends State<_ResidentActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled;
    final background = _hovered && active
        ? AppColors.hoverBackground
        : AppColors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: background,
            border: Border(
              top: BorderSide(color: AppColors.green.withAlpha(70), width: 1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: AppTypography.mono(
              color: active
                  ? AppColors.bluishWhite.withAlpha(220)
                  : AppColors.bluishWhite.withAlpha(90),
              fontSize: 20,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
