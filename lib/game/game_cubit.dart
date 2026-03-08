import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';
import '../models/citizen.dart';
import '../systems/citizen_generator.dart';
import '../systems/report_generator.dart';
import '../consts.dart';

class GameCubit extends Cubit<GameState> {
  // Accumulate dt and only emit state when enough time has elapsed.
  // This caps the BLoC stream to ~10 updates/sec instead of 60fps,
  // reducing unnecessary BlocBuilder predicate evaluations.
  double _pendingDt = 0.0;
  static const double _emitThreshold = 0.1;

  // Citizens are generated once when the game session starts and persist
  // across day rollovers. Only detaining removes citizens from this pool.
  GameCubit()
    : super(
        GameState.initial().copyWith(
          todayCitizens: CitizenGenerator.generateDailyCitizens(30),
        ),
      );

  void _startNewDay({required int newDay, required double currentThreat}) {
    // Generate a fresh intelligence report for the incoming day and pause
    // gameplay until the player acknowledges the briefing.
    final report = ReportGenerator.generate(newDay);
    emit(
      state.copyWith(
        remainingTimeInDay: Consts.dayDuration,
        currentDay: newDay,
        terroristThreat: currentThreat,
        currentReport: report,
        isReportPending: true,
      ),
    );
  }

  /// Resumes gameplay after the player dismisses the intelligence briefing.
  void acknowledgeReport() {
    emit(state.copyWith(isReportPending: false));
  }

  /// Updates the time and threat based on delta time (dt).
  void tick(double dt) {
    // Pause the game loop while the intelligence report overlay is visible.
    if (state.isReportPending) return;
    if (state.terroristThreat >= 100.0) return;

    _pendingDt += dt;
    if (_pendingDt < _emitThreshold) return;

    final effectiveDt = _pendingDt;
    _pendingDt = 0.0;

    double newTime = state.remainingTimeInDay - effectiveDt;
    double newThreat =
        (state.terroristThreat + Consts.threatRatePerSecond * effectiveDt)
            .clamp(0.0, 100.0);

    if (newThreat >= 100.0) {
      // TODO: Handle game over condition
    }

    if (newTime <= 0) {
      _startNewDay(newDay: state.currentDay + 1, currentThreat: newThreat);
      return;
    }

    emit(
      state.copyWith(remainingTimeInDay: newTime, terroristThreat: newThreat),
    );
  }

  /// Action: Detain a citizen.
  /// The citizen remains in the database but is marked as detained.
  /// Threat impact is evaluated using [effectiveRiskScore], which includes
  /// the day's intelligence report modifier if the citizen matches.
  void detainCitizen(Citizen citizen) {
    if (citizen.isDetained) return;

    final updatedCitizens = state.todayCitizens.map((c) {
      if (c.idNumber == citizen.idNumber) {
        return c.copyWith(isDetained: true);
      }
      return c;
    }).toList();

    double newThreat = state.terroristThreat;

    // Use effectiveRiskScore so the daily intelligence modifier participates
    // in the threat calculation without altering the stored base riskScore.
    final effective = citizen.effectiveRiskScore(state.currentReport);
    if (effective > 60) {
      newThreat = (newThreat - 10.0).clamp(0.0, 100.0);
    } else if (effective < 40) {
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
