import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';
import '../models/resident.dart';
import '../systems/resident_generator.dart';
import '../systems/news_report_generator.dart';
import '../systems/report_generator.dart';
import '../consts.dart';

class GameCubit extends Cubit<GameState> {
  static final Random _random = Random();

  // Accumulate dt and only emit state when enough time has elapsed.
  // This caps the BLoC stream to ~10 updates/sec instead of 60fps,
  // reducing unnecessary BlocBuilder predicate evaluations.
  double _pendingDt = 0.0;

  // Drives dynamic intelligence drift every N seconds.
  double _riskDriftAccumulator = 0.0;

  // Hidden threat pressure sampled at a lower cadence.
  double _highRiskPressureAccumulator = 0.0;
  int _sampledHighRiskFreeCount = 0;

  GameState _freshSimulationState() {
    return GameState.initial().copyWith(
      hasStartedGame: true,
      isGameOver: false,
      todayResidents: ResidentGenerator.generateDailyResidents(
        Consts.residentsPerDay,
      ),
    );
  }

  void _resetInternalTimers() {
    _pendingDt = 0.0;
    _riskDriftAccumulator = 0.0;
    _highRiskPressureAccumulator = 0.0;
    _sampledHighRiskFreeCount = 0;
  }

  // Residents are generated once when the game session starts and persist
  // across day rollovers. Only detaining removes residents from this pool.
  GameCubit() : super(GameState.initial());

  void startNewSimulation() {
    _resetInternalTimers();
    emit(_freshSimulationState());
  }

  void restartSimulation() {
    startNewSimulation();
  }

  void _startNewDay({required int newDay, required double currentThreat}) {
    _highRiskPressureAccumulator = 0.0;
    _sampledHighRiskFreeCount = 0;

    // Generate both daily reports. Flow is:
    // 1) show news bulletin
    // 2) show intelligence briefing
    // 3) resume gameplay
    final newsReport = NewsReportGenerator.generate(newDay);
    final report = ReportGenerator.generate(newDay);
    emit(
      state.copyWith(
        hasStartedGame: true,
        remainingTimeInDay: Consts.dayDuration,
        currentDay: newDay,
        terroristThreat: currentThreat,
        currentNewsReport: newsReport,
        isNewsReportPending: true,
        currentReport: report,
        isReportPending: false,
        isCctvEventPending: false,
      ),
    );
  }

  /// Advances from the news bulletin to the intelligence briefing.
  void acknowledgeNewsReport() {
    // Emit in two steps so the news dialog closes before the intelligence
    // dialog is requested by UI listeners.
    emit(state.copyWith(isNewsReportPending: false, isReportPending: false));
    emit(state.copyWith(isNewsReportPending: false, isReportPending: true));
  }

  /// Resumes gameplay after the player dismisses the intelligence briefing.
  void acknowledgeReport() {
    emit(state.copyWith(isNewsReportPending: false, isReportPending: false));
    emit(state.copyWith(isReportPending: false));
  }

  /// Updates the time and threat based on delta time (dt).
  void tick(double dt) {
    // Pause the game loop while any report overlay is visible.
    if (!state.hasStartedGame || state.isGameOver) return;
    if (state.isNewsReportPending ||
        state.isReportPending ||
        state.isCctvEventPending) {
      return;
    }
    if (state.terroristThreat >= Consts.maxThreatLevel) return;

    _pendingDt += dt;
    if (_pendingDt < Consts.stateEmitThresholdSeconds) return;

    final effectiveDt = _pendingDt;
    _pendingDt = 0.0;

    double newTime = state.remainingTimeInDay - effectiveDt;
    double newThreat =
        (state.terroristThreat + Consts.threatRatePerSecond * effectiveDt)
            .clamp(Consts.minThreatLevel, Consts.maxThreatLevel);

    if (newThreat >= Consts.maxThreatLevel) {
      emit(
        state.copyWith(
          hasStartedGame: true,
          isGameOver: true,
          terroristThreat: Consts.maxThreatLevel,
          isNewsReportPending: false,
          isReportPending: false,
          isCctvEventPending: false,
        ),
      );
      return;
    }

    if (newTime <= 0) {
      _startNewDay(newDay: state.currentDay + 1, currentThreat: newThreat);
      return;
    }

    final updatedResidents = List<Resident>.from(state.todayResidents);
    _riskDriftAccumulator += effectiveDt;
    while (_riskDriftAccumulator >= Consts.riskDriftIntervalSeconds) {
      _riskDriftAccumulator -= Consts.riskDriftIntervalSeconds;
      _applyRiskDrift(updatedResidents);
    }

    // Sample how many high-risk residents remain free every 5 seconds.
    _highRiskPressureAccumulator += effectiveDt;
    while (_highRiskPressureAccumulator >=
        Consts.highRiskPressureCheckIntervalSeconds) {
      _highRiskPressureAccumulator -=
          Consts.highRiskPressureCheckIntervalSeconds;
      _sampledHighRiskFreeCount = _countHighRiskFreeResidents(updatedResidents);
    }

    if (_sampledHighRiskFreeCount > Consts.highRiskPressureTriggerCount) {
      final hiddenThreatRate =
          Consts.highRiskPressureBasePerSecond +
          (Consts.highRiskPressurePerResidentPerSecond *
              _sampledHighRiskFreeCount);
      newThreat = (newThreat + hiddenThreatRate * effectiveDt).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
    }

    final gameOver = newThreat >= Consts.maxThreatLevel;

    emit(
      state.copyWith(
        hasStartedGame: true,
        isGameOver: gameOver,
        remainingTimeInDay: newTime,
        terroristThreat: newThreat,
        todayResidents: updatedResidents,
        isNewsReportPending: gameOver ? false : state.isNewsReportPending,
        isReportPending: gameOver ? false : state.isReportPending,
        isCctvEventPending: gameOver ? false : state.isCctvEventPending,
      ),
    );
  }

  void _applyRiskDrift(List<Resident> residents) {
    if (residents.isEmpty) return;

    final sampleSize = residents.length < Consts.riskDriftSampleSize
        ? residents.length
        : Consts.riskDriftSampleSize;
    final shuffledIndices = List<int>.generate(residents.length, (i) => i)
      ..shuffle(_random);
    final selectedIndices = shuffledIndices.take(sampleSize);

    // Keep >70 risk residents uncommon by capping them around ~10% of the pool.
    final maxHighRisk = residents.length < 10
        ? Consts.highRiskCapMinCount
        : (residents.length * Consts.highRiskCapRatio).ceil();
    int highRiskCount = residents
        .where((c) => c.riskScore > Consts.highRiskThreshold)
        .length;

    for (final index in selectedIndices) {
      final resident = residents[index];
      final current = resident.riskScore;

      var delta = _random.nextBool()
          ? Consts.riskDriftStep
          : -Consts.riskDriftStep;

      // If high-risk population is already at cap, avoid creating another >70.
      if (delta > 0 &&
          current <= Consts.highRiskThreshold &&
          (current + delta) > Consts.highRiskThreshold) {
        if (highRiskCount >= maxHighRisk) {
          delta = -Consts.riskDriftStep;
        }
      }

      // Nudge existing high-risk residents downward more often to keep rarity.
      if (current > Consts.highRiskThreshold &&
          _random.nextDouble() < Consts.driftHighRiskReductionChance) {
        delta = -Consts.riskDriftStep;
      }

      final next = (current + delta).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
      final wasHigh = current > Consts.highRiskThreshold;
      final isHigh = next > Consts.highRiskThreshold;
      if (!wasHigh && isHigh) highRiskCount += 1;
      if (wasHigh && !isHigh) highRiskCount -= 1;

      residents[index] = resident.copyWith(riskScore: next);
    }
  }

  int _countHighRiskFreeResidents(List<Resident> residents) {
    return residents
        .where((c) => !c.isDetained && c.riskScore > Consts.highRiskThreshold)
        .length;
  }

  /// Triggers the CCTV surveillance mini-game overlay.
  void triggerCctvEvent() {
    emit(state.copyWith(isCctvEventPending: true));
  }

  /// Called by [CCTVOverlay] when the player resolves the mini-game.
  /// [success] = true → player clicked the red face in time.
  void resolveCctvEvent(bool success) {
    if (state.isGameOver) return;
    final delta = success
        ? -Consts.cctvSuccessThreatDelta
        : Consts.cctvFailureThreatDelta;
    final newThreat = (state.terroristThreat + delta).clamp(
      Consts.minThreatLevel,
      Consts.maxThreatLevel,
    );
    final gameOver = newThreat >= Consts.maxThreatLevel;
    emit(
      state.copyWith(
        hasStartedGame: true,
        isGameOver: gameOver,
        isCctvEventPending: false,
        terroristThreat: newThreat,
      ),
    );
  }

  /// Action: Detain a resident.
  /// The resident remains in the database but is marked as detained.
  /// Threat impact is evaluated using [effectiveRiskScore], which includes
  /// the day's intelligence report modifier if the resident matches.
  void detainResident(Resident resident) {
    if (state.isGameOver || resident.isDetained) return;

    final updatedResidents = state.todayResidents.map((c) {
      if (c.id == resident.id) {
        return c.copyWith(isDetained: true);
      }
      return c;
    }).toList();

    double newThreat = state.terroristThreat;

    // Use effectiveRiskScore so the daily intelligence modifier participates
    // in the threat calculation without altering the stored base riskScore.
    final effective = resident.effectiveRiskScore(state.currentReport);
    if (effective > Consts.detainGoodThreshold) {
      newThreat = (newThreat - Consts.detainThreatDelta).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
    } else if (effective < Consts.detainBadThreshold) {
      newThreat = (newThreat + Consts.detainThreatDelta).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
    }

    final gameOver = newThreat >= Consts.maxThreatLevel;

    emit(
      state.copyWith(
        hasStartedGame: true,
        isGameOver: gameOver,
        detaineeCount: state.detaineeCount + 1,
        todayResidents: updatedResidents,
        terroristThreat: newThreat,
        isNewsReportPending: gameOver ? false : state.isNewsReportPending,
        isReportPending: gameOver ? false : state.isReportPending,
        isCctvEventPending: gameOver ? false : state.isCctvEventPending,
      ),
    );
  }

  /// Action: Investigate a resident.
  void investigateResident(Resident resident) {
    if (state.isGameOver) return;
    if (!resident.isInvestigated) {
      final updatedResidents = state.todayResidents.map((c) {
        if (c.id == resident.id) {
          return c.copyWith(isInvestigated: true);
        }
        return c;
      }).toList();

      emit(
        state.copyWith(
          hasStartedGame: true,
          investigationCount: state.investigationCount + 1,
          todayResidents: updatedResidents,
        ),
      );
    }
  }
}
