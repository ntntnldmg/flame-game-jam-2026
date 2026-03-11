import 'package:bigbrother/consts.dart';
import 'package:equatable/equatable.dart';
import '../models/resident.dart';
import '../models/intelligence_report.dart';
import '../models/news_report.dart';

class GameState extends Equatable {
  final int currentDay;
  final double terroristThreat; // 0.0 to 100.0
  final int detaineeCount;
  final int investigationCount;
  final double remainingTimeInDay;
  final List<Resident> todayResidents;

  /// The active intelligence briefing for the current day. Null on day 1.
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
    required this.currentDay,
    required this.terroristThreat,
    required this.detaineeCount,
    required this.investigationCount,
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
      detaineeCount: 0,
      investigationCount: 0,
      remainingTimeInDay: Consts.dayDuration,
      todayResidents: [],
    );
  }

  /// Helper to copy the state with updated fields.
  GameState copyWith({
    int? currentDay,
    double? terroristThreat,
    int? detaineeCount,
    int? investigationCount,
    double? remainingTimeInDay,
    List<Resident>? todayResidents,
    IntelligenceReport? currentReport,
    NewsReport? currentNewsReport,
    bool? isNewsReportPending,
    bool? isReportPending,
    bool? isCctvEventPending,
  }) {
    return GameState(
      currentDay: currentDay ?? this.currentDay,
      terroristThreat: terroristThreat ?? this.terroristThreat,
      detaineeCount: detaineeCount ?? this.detaineeCount,
      investigationCount: investigationCount ?? this.investigationCount,
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

  @override
  List<Object?> get props => [
    currentDay,
    terroristThreat,
    detaineeCount,
    investigationCount,
    remainingTimeInDay,
    todayResidents,
    currentReport,
    currentNewsReport,
    isNewsReportPending,
    isReportPending,
    isCctvEventPending,
  ];
}
