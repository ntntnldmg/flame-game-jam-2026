import 'package:bigbrother/consts.dart';
import 'package:equatable/equatable.dart';
import '../models/resident.dart';
import '../models/intelligence_report.dart';
import '../models/news_report.dart';

class GameState extends Equatable {
  final bool hasStartedGame;
  final bool isGameOver;
  final int currentDay;
  final double terroristThreat; // 0.0 to 100.0
  final int arrestCount;
  final int investigationCount;
  final int investigationsUsedToday;
  final int arrestsUsedToday;
  final int wireTapsUsedToday;
  final double remainingTimeInDay;
  final List<Resident> todayResidents;

  /// The active intelligence briefing for the current day.
  final IntelligenceReport? currentReport;

  /// The active atmospheric news bulletin for the current day.
  final NewsReport? currentNewsReport;

  /// True while the news report overlay is being shown.
  final bool isNewsReportPending;

  /// True while the intelligence report overlay is being shown.
  /// The game tick is paused until the player acknowledges the report.
  final bool isReportPending;

  /// True while the CCTV surveillance mini-game overlay is active.
  final bool isCctvEventPending;

  const GameState({
    this.hasStartedGame = false,
    this.isGameOver = false,
    required this.currentDay,
    required this.terroristThreat,
    required this.arrestCount,
    required this.investigationCount,
    this.investigationsUsedToday = 0,
    this.arrestsUsedToday = 0,
    this.wireTapsUsedToday = 0,
    required this.remainingTimeInDay,
    required this.todayResidents,
    this.currentReport,
    this.currentNewsReport,
    this.isNewsReportPending = false,
    this.isReportPending = false,
    this.isCctvEventPending = false,
  });

  /// Factory for the initial game state.
  factory GameState.initial() {
    return const GameState(
      currentDay: 1,
      terroristThreat: Consts.initialThreatLevel,
      arrestCount: 0,
      investigationCount: 0,
      investigationsUsedToday: 0,
      arrestsUsedToday: 0,
      wireTapsUsedToday: 0,
      remainingTimeInDay: Consts.dayDuration,
      todayResidents: [],
    );
  }

  /// Helper to copy the state with updated fields.
  GameState copyWith({
    bool? hasStartedGame,
    bool? isGameOver,
    int? currentDay,
    double? terroristThreat,
    int? arrestCount,
    int? investigationCount,
    int? investigationsUsedToday,
    int? arrestsUsedToday,
    int? wireTapsUsedToday,
    double? remainingTimeInDay,
    List<Resident>? todayResidents,
    IntelligenceReport? currentReport,
    NewsReport? currentNewsReport,
    bool? isNewsReportPending,
    bool? isReportPending,
    bool? isCctvEventPending,
  }) {
    return GameState(
      hasStartedGame: hasStartedGame ?? this.hasStartedGame,
      isGameOver: isGameOver ?? this.isGameOver,
      currentDay: currentDay ?? this.currentDay,
      terroristThreat: terroristThreat ?? this.terroristThreat,
      arrestCount: arrestCount ?? this.arrestCount,
      investigationCount: investigationCount ?? this.investigationCount,
      investigationsUsedToday:
          investigationsUsedToday ?? this.investigationsUsedToday,
      arrestsUsedToday: arrestsUsedToday ?? this.arrestsUsedToday,
      wireTapsUsedToday: wireTapsUsedToday ?? this.wireTapsUsedToday,
      remainingTimeInDay: remainingTimeInDay ?? this.remainingTimeInDay,
      todayResidents: todayResidents ?? this.todayResidents,
      currentReport: currentReport ?? this.currentReport,
      currentNewsReport: currentNewsReport ?? this.currentNewsReport,
      isNewsReportPending: isNewsReportPending ?? this.isNewsReportPending,
      isReportPending: isReportPending ?? this.isReportPending,
      isCctvEventPending: isCctvEventPending ?? this.isCctvEventPending,
    );
  }

  int get remainingTimeInDayInt => remainingTimeInDay.ceil();

  int get remainingInvestigationsToday =>
      (Consts.maxInvestigationsPerDay - investigationsUsedToday)
          .clamp(0, Consts.maxInvestigationsPerDay)
          .toInt();

  int get remainingArrestsToday => (Consts.maxArrestsPerDay - arrestsUsedToday)
      .clamp(0, Consts.maxArrestsPerDay)
      .toInt();

  int get remainingWireTapsToday =>
      (Consts.maxWireTapsPerDay - wireTapsUsedToday)
          .clamp(0, Consts.maxWireTapsPerDay)
          .toInt();

  @override
  List<Object?> get props => [
    hasStartedGame,
    isGameOver,
    currentDay,
    terroristThreat,
    arrestCount,
    investigationCount,
    investigationsUsedToday,
    arrestsUsedToday,
    wireTapsUsedToday,
    remainingTimeInDay,
    todayResidents,
    currentReport,
    currentNewsReport,
    isNewsReportPending,
    isReportPending,
    isCctvEventPending,
  ];
}
