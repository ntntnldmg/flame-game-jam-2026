import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';
import '../models/resident.dart';
import '../systems/resident_generator.dart';
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

  // Threat rises in visible bursts instead of continuously.
  double _pendingPassiveThreat = 0.0;
  double _threatPauseRemaining = 0.0;

  GameState _freshSimulationState() {
    final report = ReportGenerator.generate(1);

    return GameState.initial().copyWith(
      hasStartedGame: true,
      isGameOver: false,
      isTrueEnding: false,
      todayResidents: ResidentGenerator.generateDailyResidents(
        Consts.residentsPerDay,
      ),
      isNewsReportPending: false,
      currentReport: report,
      isReportPending: true,
      isReopenedReport: false,
      isCctvEventPending: false,
      isEpiloguePending: false,
    );
  }

  void _resetInternalTimers() {
    _pendingDt = 0.0;
    _riskDriftAccumulator = 0.0;
    _highRiskPressureAccumulator = 0.0;
    _sampledHighRiskFreeCount = 0;
    _pendingPassiveThreat = 0.0;
    _threatPauseRemaining = _nextThreatPauseSeconds();
  }

  // Residents are generated once when the game session starts and persist
  // across day rollovers.
  GameCubit() : super(GameState.initial());

  void startNewSimulation() {
    _resetInternalTimers();
    emit(_freshSimulationState());
  }

  void restartSimulation() {
    _resetInternalTimers();

    // Two-phase reset prevents overlay route races:
    // 1) clear game-over/pending flags and return to a pristine state
    // 2) on the next microtask, start a fresh simulation (day 1 reports etc.)
    emit(GameState.initial());
    Future.microtask(() {
      if (isClosed) return;
      emit(_freshSimulationState());
    });
  }

  void _startNewDay({required int newDay, required double currentThreat}) {
    _highRiskPressureAccumulator = 0.0;
    _sampledHighRiskFreeCount = 0;
    _pendingPassiveThreat = 0.0;
    _threatPauseRemaining = _nextThreatPauseSeconds();

    // Generate one combined daily report.
    final report = ReportGenerator.generate(newDay);
    emit(
      state.copyWith(
        hasStartedGame: true,
        remainingTimeInDay: Consts.dayDuration,
        currentDay: newDay,
        investigationsUsedToday: 0,
        arrestsUsedToday: 0,
        wireTapsUsedToday: 0,
        terroristThreat: currentThreat,
        isNewsReportPending: false,
        currentReport: report,
        isReportPending: true,
        isReopenedReport: false,
        isCctvEventPending: false,
        isEpiloguePending: false,
        isTrueEnding: false,
      ),
    );
  }

  /// Legacy no-op: reports are now combined into one daily briefing.
  void acknowledgeNewsReport() {
    acknowledgeReport();
  }

  /// Resumes gameplay after the player dismisses the intelligence briefing.
  void acknowledgeReport() {
    emit(
      state.copyWith(
        isNewsReportPending: false,
        isReportPending: false,
        isReopenedReport: false,
      ),
    );
    emit(state.copyWith(isReportPending: false, isReopenedReport: false));
  }

  /// Reopens the current day's intelligence report in the middle of gameplay.
  void reopenCurrentReport() {
    if (state.currentReport == null) return;
    if (state.isGameOver ||
        state.isEpiloguePending ||
        state.isCctvEventPending) {
      return;
    }
    if (state.isReportPending) return;

    emit(
      state.copyWith(
        isNewsReportPending: false,
        isReportPending: true,
        isReopenedReport: true,
      ),
    );
  }

  /// Updates the time and threat based on delta time (dt).
  void tick(double dt) {
    // Pause the game loop while any report overlay is visible.
    if (!state.hasStartedGame || state.isGameOver) return;
    if (state.isNewsReportPending ||
        state.isReportPending ||
        state.isCctvEventPending ||
        state.isEpiloguePending) {
      return;
    }
    if (state.terroristThreat >= Consts.maxThreatLevel) return;

    _pendingDt += dt;
    if (_pendingDt < Consts.stateEmitThresholdSeconds) return;

    final effectiveDt = _pendingDt;
    _pendingDt = 0.0;

    double newTime = state.remainingTimeInDay - effectiveDt;
    double passiveThreatDelta = Consts.threatRatePerSecond * effectiveDt;
    double newThreat = state.terroristThreat;

    if (newTime <= 0) {
      if (state.currentDay >= 5) {
        _triggerEpilogueAtDayFiveEnd(
          newThreat: newThreat,
          updatedResidents: List<Resident>.from(state.todayResidents),
          completedInvestigations: 0,
          completedArrests: 0,
        );
        return;
      }
      _startNewDay(newDay: state.currentDay + 1, currentThreat: newThreat);
      return;
    }

    final updatedResidents = List<Resident>.from(state.todayResidents);

    var completedInvestigations = 0;
    var completedArrests = 0;
    _processResidentActionCompletions(
      updatedResidents,
      effectiveDt,
      onInvestigationCompleted: () => completedInvestigations += 1,
      onArrestCompleted: () => completedArrests += 1,
    );

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
      passiveThreatDelta += hiddenThreatRate * effectiveDt;
    }

    newThreat =
        (newThreat +
                _releasePassiveThreatBurst(
                  dt: effectiveDt,
                  passiveThreatDelta: passiveThreatDelta,
                ))
            .clamp(Consts.minThreatLevel, Consts.maxThreatLevel);

    if (newThreat >= Consts.maxThreatLevel) {
      emit(
        state.copyWith(
          hasStartedGame: true,
          isGameOver: true,
          isTrueEnding: false,
          remainingTimeInDay: newTime,
          investigationCount:
              state.investigationCount + completedInvestigations,
          arrestCount: state.arrestCount + completedArrests,
          terroristThreat: newThreat,
          todayResidents: updatedResidents,
          isNewsReportPending: false,
          isReportPending: false,
          isCctvEventPending: false,
          isEpiloguePending: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasStartedGame: true,
        isGameOver: false,
        remainingTimeInDay: newTime,
        investigationCount: state.investigationCount + completedInvestigations,
        arrestCount: state.arrestCount + completedArrests,
        terroristThreat: newThreat,
        todayResidents: updatedResidents,
        isNewsReportPending: false,
        isReportPending: state.isReportPending,
        isCctvEventPending: state.isCctvEventPending,
        isEpiloguePending: false,
      ),
    );
  }

  void _triggerEpilogueAtDayFiveEnd({
    required double newThreat,
    required List<Resident> updatedResidents,
    required int completedInvestigations,
    required int completedArrests,
  }) {
    emit(
      state.copyWith(
        hasStartedGame: true,
        isGameOver: false,
        remainingTimeInDay: 0,
        investigationCount: state.investigationCount + completedInvestigations,
        arrestCount: state.arrestCount + completedArrests,
        terroristThreat: newThreat,
        todayResidents: updatedResidents,
        isNewsReportPending: false,
        isReportPending: false,
        isCctvEventPending: false,
        isEpiloguePending: true,
        isTrueEnding: false,
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
        .where(
          (c) =>
              !c.isArrested &&
              c.effectiveRiskScore(state.currentReport) >
                  Consts.highRiskThreshold,
        )
        .length;
  }

  void _processResidentActionCompletions(
    List<Resident> residents,
    double dt, {
    required void Function() onInvestigationCompleted,
    required void Function() onArrestCompleted,
  }) {
    for (var i = 0; i < residents.length; i++) {
      var resident = residents[i];

      if (resident.isInvestigationPending &&
          resident.investigationRemainingSeconds != null) {
        final nextRemaining = resident.investigationRemainingSeconds! - dt;
        if (nextRemaining <= 0) {
          resident = resident.copyWith(
            isInvestigated: true,
            isInvestigationPending: false,
            clearInvestigationRemainingSeconds: true,
            hasInvestigationCompletedMarker: true,
          );
          onInvestigationCompleted();
        } else {
          resident = resident.copyWith(
            investigationRemainingSeconds: nextRemaining,
          );
        }
      }

      if (resident.isArrestPending && resident.arrestRemainingSeconds != null) {
        final nextRemaining = resident.arrestRemainingSeconds! - dt;
        if (nextRemaining <= 0) {
          resident = resident.copyWith(
            isArrested: true,
            isArrestPending: false,
            clearArrestRemainingSeconds: true,
            hasArrestCompletedMarker: true,
          );
          onArrestCompleted();
        } else {
          resident = resident.copyWith(arrestRemainingSeconds: nextRemaining);
        }
      }

      residents[i] = resident;
    }
  }

  double _randomDelaySeconds({required int min, required int max}) =>
      min + _random.nextInt(max - min + 1).toDouble();

  double _nextThreatPauseSeconds() {
    return Consts.threatPauseMinSeconds.toDouble() +
        _random.nextInt(
          Consts.threatPauseMaxSeconds - Consts.threatPauseMinSeconds + 1,
        );
  }

  double _releasePassiveThreatBurst({
    required double dt,
    required double passiveThreatDelta,
  }) {
    if (dt <= 0) return 0.0;

    var releasedThreat = 0.0;
    var remainingDt = dt;
    final passiveThreatRate = passiveThreatDelta / dt;

    while (remainingDt > 0) {
      if (_threatPauseRemaining <= 0) {
        _threatPauseRemaining = _nextThreatPauseSeconds();
      }

      final chunk = remainingDt < _threatPauseRemaining
          ? remainingDt
          : _threatPauseRemaining;

      _pendingPassiveThreat += passiveThreatRate * chunk;
      _threatPauseRemaining -= chunk;
      remainingDt -= chunk;

      if (_threatPauseRemaining <= 0) {
        releasedThreat += _pendingPassiveThreat;
        _pendingPassiveThreat = 0.0;
        _threatPauseRemaining = _nextThreatPauseSeconds();
      }
    }

    return releasedThreat / 9;
  }

  Resident? _findResidentById(String id) {
    for (final resident in state.todayResidents) {
      if (resident.id == id) return resident;
    }
    return null;
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
    if (newThreat >= Consts.maxThreatLevel) {
      emit(
        state.copyWith(
          hasStartedGame: true,
          isGameOver: true,
          isTrueEnding: false,
          isCctvEventPending: false,
          isNewsReportPending: false,
          isReportPending: false,
          isEpiloguePending: false,
          terroristThreat: newThreat,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        hasStartedGame: true,
        isGameOver: false,
        isCctvEventPending: false,
        isEpiloguePending: false,
        terroristThreat: newThreat,
      ),
    );
  }

  /// Called when the 2-part epilogue sequence has finished.
  void completeEpilogue() {
    // Transition atomically to prevent the game tick from re-triggering
    // day-5 epilogue in a transient non-gameover frame.
    emit(
      state.copyWith(
        hasStartedGame: true,
        isEpiloguePending: false,
        isGameOver: true,
        isTrueEnding: true,
      ),
    );
  }

  /// Action: Order an investigation that completes after a random delay.
  void orderInvestigation(Resident resident) {
    if (state.isGameOver) return;
    if (state.investigationsUsedToday >= Consts.maxInvestigationsPerDay) {
      return;
    }

    final current = _findResidentById(resident.id);
    if (current == null ||
        current.isInvestigated ||
        current.isInvestigationPending ||
        current.isArrested) {
      return;
    }

    final updatedResidents = state.todayResidents.map((c) {
      if (c.id != resident.id) return c;
      return c.copyWith(
        isInvestigationPending: true,
        investigationRemainingSeconds: _randomDelaySeconds(
          min: Consts.investigationDelayMinSeconds,
          max: Consts.investigationDelayMaxSeconds,
        ),
      );
    }).toList();

    emit(
      state.copyWith(
        hasStartedGame: true,
        investigationsUsedToday: state.investigationsUsedToday + 1,
        todayResidents: updatedResidents,
      ),
    );
  }

  /// Action: Issue an arrest warrant that completes after a random delay.
  void issueArrestWarrant(Resident resident) {
    if (state.isGameOver) return;
    if (state.arrestsUsedToday >= Consts.maxArrestsPerDay) return;

    final current = _findResidentById(resident.id);
    if (current == null || current.isArrested || current.isArrestPending) {
      return;
    }

    final updatedResidents = state.todayResidents.map((c) {
      if (c.id != resident.id) return c;
      return c.copyWith(
        isArrestPending: true,
        arrestRemainingSeconds: _randomDelaySeconds(
          min: Consts.arrestDelayMinSeconds,
          max: Consts.arrestDelayMaxSeconds,
        ),
      );
    }).toList();

    emit(
      state.copyWith(
        hasStartedGame: true,
        arrestsUsedToday: state.arrestsUsedToday + 1,
        todayResidents: updatedResidents,
      ),
    );
  }

  /// Action: Install a wire tap immediately.
  void installWireTap(Resident resident) {
    if (state.isGameOver) return;
    if (state.wireTapsUsedToday >= Consts.maxWireTapsPerDay) return;

    final current = _findResidentById(resident.id);
    if (current == null || current.hasWireTap) return;

    final updatedResidents = state.todayResidents.map((c) {
      if (c.id != resident.id) return c;
      return c.copyWith(hasWireTap: true);
    }).toList();

    emit(
      state.copyWith(
        hasStartedGame: true,
        wireTapsUsedToday: state.wireTapsUsedToday + 1,
        todayResidents: updatedResidents,
      ),
    );
  }

  /// Adds a newly identified unregistered resident to today's database.
  void registerResidentFromCctv(Resident resident) {
    if (state.isGameOver) return;
    if (state.todayResidents.any((r) => r.id == resident.id)) return;

    final updatedResidents = List<Resident>.from(state.todayResidents)
      ..add(resident);

    emit(
      state.copyWith(hasStartedGame: true, todayResidents: updatedResidents),
    );
  }

  /// Clears per-resident completion markers after the player reviews details.
  void clearResidentCompletionMarkers(String residentId) {
    final updatedResidents = state.todayResidents.map((c) {
      if (c.id != residentId) return c;
      return c.copyWith(
        hasInvestigationCompletedMarker: false,
        hasArrestCompletedMarker: false,
      );
    }).toList();

    emit(
      state.copyWith(hasStartedGame: true, todayResidents: updatedResidents),
    );
  }
}
