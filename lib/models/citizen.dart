/// Represents a citizen in the game world.
class Citizen {
  final String idNumber;
  final String ageGroup;
  final String occupation;
  final String religion;
  final String ethnicity;

  /// Hidden from player
  final double riskScore;

  /// Track if the player has investigated this citizen
  bool isInvestigated;

  Citizen({
    required this.idNumber,
    required this.ageGroup,
    required this.occupation,
    required this.religion,
    required this.ethnicity,
    required this.riskScore,
    this.isInvestigated = false,
  });
}
