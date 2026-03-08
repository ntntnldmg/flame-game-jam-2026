import 'package:equatable/equatable.dart';

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

  const Citizen({
    required this.idNumber,
    required this.ageGroup,
    required this.occupation,
    required this.religion,
    required this.ethnicity,
    required this.riskScore,
    this.isInvestigated = false,
  });

  Citizen copyWith({
    String? idNumber,
    String? ageGroup,
    String? occupation,
    String? religion,
    String? ethnicity,
    double? riskScore,
    bool? isInvestigated,
  }) {
    return Citizen(
      idNumber: idNumber ?? this.idNumber,
      ageGroup: ageGroup ?? this.ageGroup,
      occupation: occupation ?? this.occupation,
      religion: religion ?? this.religion,
      ethnicity: ethnicity ?? this.ethnicity,
      riskScore: riskScore ?? this.riskScore,
      isInvestigated: isInvestigated ?? this.isInvestigated,
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
  ];
}
