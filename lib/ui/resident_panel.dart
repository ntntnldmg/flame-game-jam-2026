import 'package:bigbrother/ui/painters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../consts.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';
import '../models/resident.dart';

class ResidentPanel extends StatelessWidget {
  const ResidentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) =>
          previous.todayResidents != current.todayResidents,
      builder: (context, state) {
        return Container(
          width: 290,
          decoration: BoxDecoration(
            color: const Color(0xFF061828),
            border: Border.all(color: AppColors.green, width: 1.5),
          ),
          child: Column(
            children: [
              _PanelHeader(entryCount: state.todayResidents.length),
              Expanded(
                child: ListView.builder(
                  itemCount: state.todayResidents.length,
                  itemBuilder: (context, index) => _ResidentRow(
                    resident: state.todayResidents[index],
                    onTap: () => _showResidentDetails(
                      context,
                      state.todayResidents[index],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResidentDetails(BuildContext context, Resident resident) {
    if (context.read<GameCubit>().state.isCctvEventPending) return;
    final cubit = context.read<GameCubit>();
    cubit.clearResidentCompletionMarkers(resident.id);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ResidentDetailDialog(residentId: resident.id, cubit: cubit);
      },
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final int entryCount;
  const _PanelHeader({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    // The title sits in its own bordered box (tab-style).
    // The entry count lives outside that box, in the remaining header space.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF071F30),
              border: Border(
                bottom: BorderSide(color: AppColors.green, width: 1.5),
                right: BorderSide(color: AppColors.green, width: 1.5),
              ),
            ),
            child: Text(
              'RESIDENT DATABASE',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.green, width: 1.5),
                ),
              ),
              alignment: Alignment.centerRight,
              child: Text(
                '$entryCount entries',
                style: TextStyle(
                  color: AppColors.bluishWhite.withAlpha(150),
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Row ─────────────────────────────────────────────────────────────────────

class _ResidentRow extends StatefulWidget {
  final Resident resident;
  final VoidCallback onTap;

  const _ResidentRow({required this.resident, required this.onTap});

  @override
  State<_ResidentRow> createState() => _ResidentRowState();
}

class _ResidentRowState extends State<_ResidentRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.resident;
    final dimmed = r.isArrested;
    final hasCompletionMarker = r.hasCompletedActionMarker;
    final isPending = r.isInvestigationPending || r.isArrestPending;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hovered ? AppColors.hoverBackground : Colors.transparent,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Barcode + ID
                    SizedBox(
                      width: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 28,
                            child: CustomPaint(
                              painter: BarcodePainter(dimmed: dimmed),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.id,
                            style: TextStyle(
                              color: dimmed
                                  ? AppColors.green.withAlpha(60)
                                  : AppColors.green.withAlpha(150),
                              fontSize: 8,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Name + details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (r.isArrested)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: AppColors.red.withAlpha(210),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  r.name.toUpperCase(),
                                  style: TextStyle(
                                    color: dimmed
                                        ? AppColors.bluishWhite.withAlpha(50)
                                        : AppColors.bluishWhite,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (r.isArrestPending)
                            Text(
                              'ARREST WARRANT IN PROGRESS',
                              style: TextStyle(
                                color: AppColors.red.withAlpha(180),
                                fontSize: 10,
                                letterSpacing: 0.6,
                              ),
                            )
                          else if (r.isInvestigationPending)
                            Text(
                              'INVESTIGATION IN PROGRESS',
                              style: TextStyle(
                                color: AppColors.green.withAlpha(200),
                                fontSize: 10,
                                letterSpacing: 0.6,
                              ),
                            )
                          else if (dimmed)
                            Text(
                              '[ARRESTED]',
                              style: TextStyle(
                                color: AppColors.red.withAlpha(160),
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            )
                          else
                            Text(
                              '${r.occupation.toUpperCase()} // ${r.district.toUpperCase()}',
                              style: TextStyle(
                                color: AppColors.green.withAlpha(190),
                                fontSize: 10,
                                letterSpacing: 0.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isPending)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 2),
                  child: Icon(Icons.schedule, size: 15, color: AppColors.green),
                ),
              // Completed action marker badge.
              if (hasCompletionMarker)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bluishWhite, width: 1),
                  ),
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: AppColors.bluishWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.green.withAlpha(40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResidentDetailDialog extends StatefulWidget {
  final String residentId;
  final GameCubit cubit;

  const _ResidentDetailDialog({required this.residentId, required this.cubit});

  @override
  State<_ResidentDetailDialog> createState() => _ResidentDetailDialogState();
}

class _ResidentDetailDialogState extends State<_ResidentDetailDialog> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) =>
          previous.todayResidents != current.todayResidents ||
          previous.investigationsUsedToday != current.investigationsUsedToday ||
          previous.arrestsUsedToday != current.arrestsUsedToday ||
          previous.wireTapsUsedToday != current.wireTapsUsedToday,
      builder: (context, state) {
        Resident? resident;
        for (final candidate in state.todayResidents) {
          if (candidate.id == widget.residentId) {
            resident = candidate;
            break;
          }
        }
        if (resident == null) {
          return AlertDialog(
            title: const Text('Resident Unavailable'),
            content: const Text('This resident record is no longer available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          );
        }

        final canOrderInvestigation =
            !resident.isInvestigated &&
            !resident.isInvestigationPending &&
            !resident.isArrested &&
            state.remainingInvestigationsToday > 0;
        final canIssueArrest =
            !resident.isArrested &&
            !resident.isArrestPending &&
            state.remainingArrestsToday > 0;
        final canInstallWireTap =
            !resident.hasWireTap && state.remainingWireTapsToday > 0;

        return AlertDialog(
          title: Text('Resident Details: ${resident.id}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${resident.id}'),
                Text('Name: ${resident.name}'),
                Text('Sex: ${resident.sex}'),
                Text('Age: ${resident.age}'),
                Text('Address: ${resident.street}, ${resident.district}'),
                Text('Phone: ${resident.phoneNumber}'),
                Text('Occupation: ${resident.occupation}'),
                Text('Status: ${resident.isArrested ? 'ARRESTED' : 'FREE'}'),
                Text('Wire Tap: ${resident.hasWireTap ? 'INSTALLED' : 'NONE'}'),
                const SizedBox(height: 10),
                if (resident.isInvestigated)
                  Text(
                    'Estimated Risk: ${resident.riskScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: resident.riskScore > Consts.arrestGoodThreshold
                          ? Colors.red
                          : Colors.greenAccent,
                    ),
                  ),
                if (resident.isInvestigationPending)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Investigation ordered...'),
                  ),
                if (resident.isArrestPending)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Arrest warrant issued...'),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'ACTIONS:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: canOrderInvestigation
                          ? () => widget.cubit.orderInvestigation(resident!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('ORDER INVESTIGATION'),
                    ),
                    ElevatedButton(
                      onPressed: canIssueArrest
                          ? () => widget.cubit.issueArrestWarrant(resident!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('ISSUE ARREST WARRANT'),
                    ),
                    ElevatedButton(
                      onPressed: canInstallWireTap
                          ? () => widget.cubit.installWireTap(resident!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('INSTALL WIRE TAP'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Remaining Today: '
                  'Investigations ${state.remainingInvestigationsToday}, '
                  'Arrests ${state.remainingArrestsToday}, '
                  'Wire Taps ${state.remainingWireTapsToday}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CLOSE',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
