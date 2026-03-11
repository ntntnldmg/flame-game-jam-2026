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
          width: 300,
          decoration: const BoxDecoration(
            color: Colors.black,
            border: Border(
              right: BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    bottom: BorderSide(color: Colors.greenAccent, width: 2),
                  ),
                ),
                width: double.infinity,
                child: const Text(
                  'RESIDENT DATABASE //',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Free residents first, detained at the bottom.
                    final sorted = [
                      ...state.todayResidents.where((r) => !r.isDetained),
                      ...state.todayResidents.where((r) => r.isDetained),
                    ];
                    return ListView.builder(
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final resident = sorted[index];
                        final dimmed = resident.isDetained;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          shape: const Border(
                            bottom: BorderSide(color: Colors.white10),
                          ),
                          title: Text(
                            '${resident.id}  ${resident.name.toUpperCase()}',
                            style: TextStyle(
                              color: dimmed
                                  ? Colors.white30
                                  : Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            dimmed
                                ? '[DETAINED] ${resident.occupation.toUpperCase()}'
                                : '${resident.occupation.toUpperCase()} // ${resident.district.toUpperCase()}',
                            style: TextStyle(
                              color: dimmed ? Colors.white24 : Colors.white70,
                            ),
                          ),
                          onTap: () => _showResidentDetails(context, resident),
                        );
                      },
                    );
                  },
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
