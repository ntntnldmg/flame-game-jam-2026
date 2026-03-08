import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_state.dart';
import '../models/citizen.dart';
import '../systems/citizen_generator.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial()) {
    _startNewDay();
  }

  void _startNewDay() {
    emit(
      state.copyWith(
        remainingTimeInDay: 60.0,
        todayCitizens: CitizenGenerator.generateDailyCitizens(30),
      ),
    );
  }

  /// Updates the time and threat based on delta time (dt).
  void tick(double dt) {
    if (state.terroristThreat >= 100.0 || state.remainingTimeInDay <= 0) return;

    double newTime = state.remainingTimeInDay - dt;
    double newThreat = state.terroristThreat + (1.0 * dt);

    if (newThreat >= 100.0) {
      newThreat = 100.0;
      // TODO: Handle game over condition
    }

    if (newTime <= 0) {
      newTime = 0;

      // End of day condition -> increment day, reset counters and citizens
      emit(
        state.copyWith(
          remainingTimeInDay: 60.0,
          currentDay: state.currentDay + 1,
          terroristThreat: newThreat,
          todayCitizens: CitizenGenerator.generateDailyCitizens(30),
        ),
      );
      return;
    }

    emit(
      state.copyWith(remainingTimeInDay: newTime, terroristThreat: newThreat),
    );
  }

  /// Action: Detain a citizen.
  void detainCitizen(Citizen citizen) {
    final updatedCitizens = List<Citizen>.from(state.todayCitizens)
      ..remove(citizen);

    double newThreat = state.terroristThreat;

    // Apply threat rules on detaining
    if (citizen.riskScore > 60) {
      newThreat = (newThreat - 10.0).clamp(0.0, 100.0);
    } else if (citizen.riskScore < 40) {
      newThreat = (newThreat + 10.0).clamp(0.0, 100.0);
    }

    emit(
      state.copyWith(
        detaineeCount: state.detaineeCount + 1,
        todayCitizens: updatedCitizens,
        terroristThreat: newThreat,
      ),
    );
  }

  /// Action: Investigate a citizen.
  void investigateCitizen(Citizen citizen) {
    if (!citizen.isInvestigated) {
      final updatedCitizens = state.todayCitizens.map((c) {
        if (c.idNumber == citizen.idNumber) {
          return c.copyWith(isInvestigated: true);
        }
        return c;
      }).toList();

      emit(
        state.copyWith(
          investigationCount: state.investigationCount + 1,
          todayCitizens: updatedCitizens,
        ),
      );
    }
  }
}
