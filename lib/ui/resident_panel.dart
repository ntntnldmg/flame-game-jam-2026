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
        // Free residents first, detained at the bottom.
        final sorted = [
          ...state.todayResidents.where((r) => !r.isDetained),
          ...state.todayResidents.where((r) => r.isDetained),
        ];
        return Container(
          width: 290,
          decoration: BoxDecoration(
            color: const Color(0xFF061828),
            border: Border.all(color: AppColors.green, width: 1.5),
          ),
          child: Column(
            children: [
              _PanelHeader(entryCount: sorted.length),
              Expanded(
                child: ListView.builder(
                  itemCount: sorted.length,
                  itemBuilder: (context, index) => _ResidentRow(
                    resident: sorted[index],
                    onTap: () => _showResidentDetails(context, sorted[index]),
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _ResidentDetailDialog(resident: resident, cubit: cubit);
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
    final dimmed = r.isDetained;
    final flagged =
        r.isInvestigated && r.riskScore > Consts.detainGoodThreshold && !dimmed;

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
                          Text(
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
                          const SizedBox(height: 2),
                          if (dimmed)
                            Text(
                              '[DETAINED]',
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
                    // High-risk flag badge
                    if (flagged)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.red, width: 1),
                        ),
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                  ],
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
  final Resident resident;
  final GameCubit cubit;

  const _ResidentDetailDialog({required this.resident, required this.cubit});

  @override
  State<_ResidentDetailDialog> createState() => _ResidentDetailDialogState();
}

class _ResidentDetailDialogState extends State<_ResidentDetailDialog> {
  late bool _isInvestigated;
  late bool _isDetained;

  @override
  void initState() {
    super.initState();
    _isInvestigated = widget.resident.isInvestigated;
    _isDetained = widget.resident.isDetained;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Resident Details: ${widget.resident.id}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ID: ${widget.resident.id}'),
          Text('Name: ${widget.resident.name}'),
          Text('Sex: ${widget.resident.sex}'),
          Text('Age: ${widget.resident.age}'),
          Text(
            'Address: ${widget.resident.street}, ${widget.resident.district}',
          ),
          Text('Phone: ${widget.resident.phoneNumber}'),
          Text('Occupation: ${widget.resident.occupation}'),
          Text('Status: ${_isDetained ? 'DETAINED' : 'FREE'}'),
          const SizedBox(height: 10),
          if (_isInvestigated)
            Text(
              'Estimated Risk: ${widget.resident.riskScore.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.resident.riskScore > Consts.detainGoodThreshold
                    ? Colors.red
                    : Colors.greenAccent,
              ),
            ),
          const SizedBox(height: 20),
          const Text('ACTIONS:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: (_isInvestigated || _isDetained)
                    ? null
                    : () {
                        widget.cubit.investigateResident(widget.resident);
                        setState(() => _isInvestigated = true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text('INVESTIGATE'),
              ),
              ElevatedButton(
                onPressed: _isDetained
                    ? null
                    : () {
                        widget.cubit.detainResident(widget.resident);
                        setState(() => _isDetained = true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('DETAIN'),
              ),
            ],
          ),
        ],
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
  }
}
