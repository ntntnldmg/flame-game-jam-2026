import 'package:bigbrother/consts.dart';
import 'package:equatable/equatable.dart';
import '../models/citizen.dart';
import '../models/intelligence_report.dart';
import '../models/news_report.dart';

class GameState extends Equatable {
  final int currentDay;
  final double terroristThreat; // 0.0 to 100.0
  final int detaineeCount;
  final int investigationCount;
  final double remainingTimeInDay;
  final List<Citizen> todayCitizens;

  /// The active intelligence briefing for the current day. Null on day 1.
  final IntelligenceReport? currentReport;

  /// The active atmospheric news bulletin for the current day.
  final NewsReport? currentNewsReport;

  /// True while the news report overlay is being shown.
  final bool isNewsReportPending;

  /// True while the intelligence report overlay is being shown.
  /// The game tick is paused until the player acknowledges the report.
  final bool isReportPending;

  const GameState({
    required this.currentDay,
    required this.terroristThreat,
    required this.detaineeCount,
    required this.investigationCount,
    required this.remainingTimeInDay,
    required this.todayCitizens,
    this.currentReport,
    this.currentNewsReport,
    this.isNewsReportPending = false,
    this.isReportPending = false,
  });

  /// Factory for the initial game state.
  factory GameState.initial() {
    return const GameState(
      currentDay: 1,
      terroristThreat: Consts.initialThreatLevel,
      detaineeCount: 0,
      investigationCount: 0,
      remainingTimeInDay: Consts.dayDuration,
      todayCitizens: [],
    );
  }

  /// Helper to copy the state with updated fields.
  GameState copyWith({
    int? currentDay,
    double? terroristThreat,
    int? detaineeCount,
    int? investigationCount,
    double? remainingTimeInDay,
    List<Citizen>? todayCitizens,
    IntelligenceReport? currentReport,
    NewsReport? currentNewsReport,
    bool? isNewsReportPending,
    bool? isReportPending,
  }) {
    return GameState(
      currentDay: currentDay ?? this.currentDay,
      terroristThreat: terroristThreat ?? this.terroristThreat,
      detaineeCount: detaineeCount ?? this.detaineeCount,
      investigationCount: investigationCount ?? this.investigationCount,
      remainingTimeInDay: remainingTimeInDay ?? this.remainingTimeInDay,
      todayCitizens: todayCitizens ?? this.todayCitizens,
      currentReport: currentReport ?? this.currentReport,
      currentNewsReport: currentNewsReport ?? this.currentNewsReport,
      isNewsReportPending: isNewsReportPending ?? this.isNewsReportPending,
      isReportPending: isReportPending ?? this.isReportPending,
    );
  }

  int get remainingTimeInDayInt => remainingTimeInDay.ceil();

  @override
  List<Object?> get props => [
    currentDay,
    terroristThreat,
    detaineeCount,
    investigationCount,
    remainingTimeInDay,
    todayCitizens,
    currentReport,
    currentNewsReport,
    isNewsReportPending,
    isReportPending,
  ];
}
