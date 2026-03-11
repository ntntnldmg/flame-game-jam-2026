import 'package:equatable/equatable.dart';

import '../consts.dart';
import 'intelligence_report.dart';

/// Represents a resident in the game world.
class Resident extends Equatable {
  final String id;
  final String name;
  final String sex;
  final int age;
  final String street;
  final String district;
  final String phoneNumber;
  final String occupation;

  /// Hidden from player
  final double riskScore;

  /// Track if the player has investigated this resident
  final bool isInvestigated;

  /// Track if the resident is currently in custody
  final bool isDetained;

  const Resident({
    required this.id,
    required this.name,
    required this.sex,
    required this.age,
    required this.street,
    required this.district,
    required this.phoneNumber,
    required this.occupation,
    required this.riskScore,
    this.isInvestigated = false,
    this.isDetained = false,
  });

  String get status => isDetained ? 'DETAINED' : 'FREE';

  Resident copyWith({
    String? id,
    String? name,
    String? sex,
    int? age,
    String? street,
    String? district,
    String? phoneNumber,
    String? occupation,
    double? riskScore,
    bool? isInvestigated,
    bool? isDetained,
  }) {
    return Resident(
      id: id ?? this.id,
      name: name ?? this.name,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      street: street ?? this.street,
      district: district ?? this.district,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      riskScore: riskScore ?? this.riskScore,
      isInvestigated: isInvestigated ?? this.isInvestigated,
      isDetained: isDetained ?? this.isDetained,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    sex,
    age,
    street,
    district,
    phoneNumber,
    occupation,
    riskScore,
    isInvestigated,
    isDetained,
  ];

  /// Returns the risk score with the daily intelligence modifier applied.
  /// The base [riskScore] is never mutated — this is a read-only calculation.
  double effectiveRiskScore(IntelligenceReport? report) {
    if (report == null) return riskScore;
    final residentValue = switch (report.focusCategory) {
      'sex' => sex,
      'age' => age.toString(),
      'occupation' => occupation,
      'district' => district,
      _ => null,
    };
    if (residentValue?.toLowerCase() == report.focusValue.toLowerCase()) {
      return (riskScore + Consts.intelligenceRiskModifier).clamp(
        Consts.minThreatLevel,
        Consts.maxThreatLevel,
      );
    }
    return riskScore;
  }
}
