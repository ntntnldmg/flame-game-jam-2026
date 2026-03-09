import 'package:equatable/equatable.dart';

import '../consts.dart';
import 'intelligence_report.dart';

/// Represents a citizen in the game world.
class Citizen extends Equatable {
  final String idNumber;
  final String ageGroup;
  final String occupation;
  final String religion;
  final String ethnicity;

  /// Hidden from player
  final double riskScore;

  /// Track if the player has investigated this citizen
  final bool isInvestigated;

  /// Track if the citizen is currently in custody
  final bool isDetained;

  const Citizen({
    required this.idNumber,
    required this.ageGroup,
    required this.occupation,
    required this.religion,
    required this.ethnicity,
    required this.riskScore,
    this.isInvestigated = false,
    this.isDetained = false,
  });

  Citizen copyWith({
    String? idNumber,
    String? ageGroup,
    String? occupation,
    String? religion,
    String? ethnicity,
    double? riskScore,
    bool? isInvestigated,
    bool? isDetained,
  }) {
    return Citizen(
      idNumber: idNumber ?? this.idNumber,
      ageGroup: ageGroup ?? this.ageGroup,
      occupation: occupation ?? this.occupation,
      religion: religion ?? this.religion,
      ethnicity: ethnicity ?? this.ethnicity,
      riskScore: riskScore ?? this.riskScore,
      isInvestigated: isInvestigated ?? this.isInvestigated,
      isDetained: isDetained ?? this.isDetained,
    );
  }

  @override
  List<Object?> get props => [
    idNumber,
    ageGroup,
    occupation,
    religion,
    ethnicity,
    riskScore,
    isInvestigated,
    isDetained,
  ];

  /// Returns the risk score with the daily intelligence modifier applied.
  /// The base [riskScore] is never mutated — this is a read-only calculation.
  double effectiveRiskScore(IntelligenceReport? report) {
    if (report == null) return riskScore;
    final citizenValue = switch (report.focusCategory) {
      'ageGroup' => ageGroup,
      'occupation' => occupation,
      'religion' => religion,
      'ethnicity' => ethnicity,
      _ => null,
    };
    if (citizenValue?.toLowerCase() == report.focusValue.toLowerCase()) {
      return (riskScore + Consts.intelligenceRiskModifier).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
    }
    return riskScore;
  }

  @override
  String toString() {
    return '''
{
  idNumber: $idNumber,
  ageGroup: $ageGroup,
  occupation: $occupation,
  religion: $religion,
  ethnicity: $ethnicity,
  riskScore: $riskScore,
  isInvestigated: $isInvestigated,
  isDetained: $isDetained
}
''';
  }
}
