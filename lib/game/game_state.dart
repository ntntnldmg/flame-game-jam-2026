import 'package:equatable/equatable.dart';
import '../models/citizen.dart';

class GameState extends Equatable {
  final int currentDay;
  final double terroristThreat; // 0.0 to 100.0
  final int detaineeCount;
  final int investigationCount;
  final double remainingTimeInDay;
  final List<Citizen> todayCitizens;

  const GameState({
    required this.currentDay,
    required this.terroristThreat,
    required this.detaineeCount,
    required this.investigationCount,
    required this.remainingTimeInDay,
    required this.todayCitizens,
  });

  /// Factory for the initial game state.
  factory GameState.initial() {
    return const GameState(
      currentDay: 1,
      terroristThreat: 0.0,
      detaineeCount: 0,
      investigationCount: 0,
      remainingTimeInDay: 60.0,
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
  }) {
    return GameState(
      currentDay: currentDay ?? this.currentDay,
      terroristThreat: terroristThreat ?? this.terroristThreat,
      detaineeCount: detaineeCount ?? this.detaineeCount,
      investigationCount: investigationCount ?? this.investigationCount,
      remainingTimeInDay: remainingTimeInDay ?? this.remainingTimeInDay,
      todayCitizens: todayCitizens ?? this.todayCitizens,
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
  ];
}
