import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/citizen.dart';
import '../game/game_state.dart';
import '../game/game_cubit.dart';

class CitizenPanel extends StatelessWidget {
  const CitizenPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) =>
          previous.todayCitizens != current.todayCitizens,
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
                  'CITIZEN DATABASE //',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.todayCitizens.length,
                  itemBuilder: (context, index) {
                    final citizen = state.todayCitizens[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      shape: const Border(
                        bottom: BorderSide(color: Colors.white10),
                      ),
                      title: Text(
                        'ID: ${citizen.idNumber}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${citizen.occupation.toUpperCase()} // AGE: ${citizen.ageGroup}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () => _showCitizenDetails(context, citizen),
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

  void _showCitizenDetails(BuildContext context, Citizen citizen) {
    final cubit = context.read<GameCubit>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CitizenDetailDialog(citizen: citizen, cubit: cubit);
      },
    );
  }
}

/// A fully self-contained dialog that does NOT subscribe to the BLoC stream.
/// Local state is managed via [setState], keeping it isolated from the
/// 60fps Flame game loop which would otherwise cause Flutter Web to crash.
class _CitizenDetailDialog extends StatefulWidget {
  final Citizen citizen;
  final GameCubit cubit;

  const _CitizenDetailDialog({required this.citizen, required this.cubit});

  @override
  State<_CitizenDetailDialog> createState() => _CitizenDetailDialogState();
}

class _CitizenDetailDialogState extends State<_CitizenDetailDialog> {
  late bool _isInvestigated;

  @override
  void initState() {
    super.initState();
    _isInvestigated = widget.citizen.isInvestigated;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Citizen Details: ${widget.citizen.idNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Age Group: ${widget.citizen.ageGroup}'),
          Text('Occupation: ${widget.citizen.occupation}'),
          Text('Religion: ${widget.citizen.religion}'),
          Text('Ethnicity: ${widget.citizen.ethnicity}'),
          const SizedBox(height: 10),
          if (_isInvestigated)
            Text(
              'Estimated Risk: ${widget.citizen.riskScore.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.citizen.riskScore > 60
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
                onPressed: _isInvestigated
                    ? null
                    : () {
                        widget.cubit.investigateCitizen(widget.citizen);
                        setState(() => _isInvestigated = true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text('INVESTIGATE'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.cubit.detainCitizen(widget.citizen);
                  Navigator.of(context).pop();
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
