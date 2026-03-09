import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_state.dart';
import '../models/citizen.dart';
import '../systems/citizen_generator.dart';
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

  // Citizens are generated once when the game session starts and persist
  // across day rollovers. Only detaining removes citizens from this pool.
  GameCubit()
    : super(
        GameState.initial().copyWith(
          todayCitizens: CitizenGenerator.generateDailyCitizens(
            Consts.citizensPerDay,
          ),
        ),
      );

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
        remainingTimeInDay: Consts.dayDuration,
        currentDay: newDay,
        terroristThreat: currentThreat,
        currentNewsReport: newsReport,
        isNewsReportPending: true,
        currentReport: report,
        isReportPending: false,
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
    if (state.isNewsReportPending || state.isReportPending) return;
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
      // TODO: Handle game over condition
    }

    if (newTime <= 0) {
      _startNewDay(newDay: state.currentDay + 1, currentThreat: newThreat);
      return;
    }

    final updatedCitizens = List<Citizen>.from(state.todayCitizens);
    _riskDriftAccumulator += effectiveDt;
    while (_riskDriftAccumulator >= Consts.riskDriftIntervalSeconds) {
      _riskDriftAccumulator -= Consts.riskDriftIntervalSeconds;
      _applyRiskDrift(updatedCitizens);
    }

    // Sample how many high-risk citizens remain free every 5 seconds.
    _highRiskPressureAccumulator += effectiveDt;
    while (_highRiskPressureAccumulator >=
        Consts.highRiskPressureCheckIntervalSeconds) {
      _highRiskPressureAccumulator -=
          Consts.highRiskPressureCheckIntervalSeconds;
      _sampledHighRiskFreeCount = _countHighRiskFreeCitizens(updatedCitizens);
    }

    if (_sampledHighRiskFreeCount > Consts.highRiskPressureTriggerCount) {
      final hiddenThreatRate =
          Consts.highRiskPressureBasePerSecond +
          (Consts.highRiskPressurePerCitizenPerSecond *
              _sampledHighRiskFreeCount);
      newThreat = (newThreat + hiddenThreatRate * effectiveDt).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
    }

    emit(
      state.copyWith(
        remainingTimeInDay: newTime,
        terroristThreat: newThreat,
        todayCitizens: updatedCitizens,
      ),
    );
  }

  void _applyRiskDrift(List<Citizen> citizens) {
    if (citizens.isEmpty) return;

    final sampleSize = citizens.length < Consts.riskDriftSampleSize
        ? citizens.length
        : Consts.riskDriftSampleSize;
    final shuffledIndices = List<int>.generate(citizens.length, (i) => i)
      ..shuffle(_random);
    final selectedIndices = shuffledIndices.take(sampleSize);

    // Keep >70 risk citizens uncommon by capping them around ~10% of the pool.
    final maxHighRisk = citizens.length < 10
        ? Consts.highRiskCapMinCount
        : (citizens.length * Consts.highRiskCapRatio).ceil();
    int highRiskCount = citizens
        .where((c) => c.riskScore > Consts.highRiskThreshold)
        .length;

    for (final index in selectedIndices) {
      final citizen = citizens[index];
      final current = citizen.riskScore;

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

      // Nudge existing high-risk citizens downward more often to keep rarity.
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

      citizens[index] = citizen.copyWith(riskScore: next);
    }
  }

  int _countHighRiskFreeCitizens(List<Citizen> citizens) {
    return citizens
        .where((c) => !c.isDetained && c.riskScore > Consts.highRiskThreshold)
        .length;
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
