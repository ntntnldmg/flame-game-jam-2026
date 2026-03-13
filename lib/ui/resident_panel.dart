import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../game/game_cubit.dart';
import '../game/game_state.dart';
import '../models/resident.dart';
import 'widgets/resident_database_header.dart';
import 'widgets/resident_details_panel.dart';
import 'widgets/resident_list_item.dart';

class ResidentPanel extends StatefulWidget {
  const ResidentPanel({super.key});

  @override
  State<ResidentPanel> createState() => _ResidentPanelState();
}

class _ResidentPanelState extends State<ResidentPanel> {
  String? _selectedResidentId;

  void _selectResident(BuildContext context, String residentId) {
    if (context.read<GameCubit>().state.isCctvEventPending) return;
    context.read<GameCubit>().clearResidentCompletionMarkers(residentId);
    setState(() => _selectedResidentId = residentId);
  }

  void _closeDetails() {
    if (!mounted) return;
    setState(() => _selectedResidentId = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      buildWhen: (previous, current) =>
          previous.todayResidents != current.todayResidents,
      builder: (context, state) {
        Resident? selectedResident;
        if (_selectedResidentId != null) {
          for (final resident in state.todayResidents) {
            if (resident.id == _selectedResidentId) {
              selectedResident = resident;
              break;
            }
          }
        }

        return Container(
          width: 290,
          decoration: BoxDecoration(
            color: const Color(0xFF061828),
            border: Border.all(color: const Color(0xff6eb5bb), width: 1.5),
          ),
          child: Column(
            children: [
              ResidentDatabaseHeader(entryCount: state.todayResidents.length),
              Expanded(
                child: selectedResident != null
                    ? ResidentDetailsPanel(
                        resident: selectedResident,
                        state: state,
                        onBack: _closeDetails,
                      )
                    : ListView.builder(
                        itemCount: state.todayResidents.length,
                        itemBuilder: (context, index) => ResidentListItem(
                          resident: state.todayResidents[index],
                          onTap: () => _selectResident(
                            context,
                            state.todayResidents[index].id,
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
}
