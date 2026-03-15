import 'package:equatable/equatable.dart';

import '../consts.dart';
import 'intelligence_report.dart';

/// Represents a resident in the game world.
class Resident extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
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

  /// True while an investigation is currently queued.
  final bool isInvestigationPending;

  /// Seconds remaining for the queued investigation.
  final double? investigationRemainingSeconds;

  /// Track if the resident is currently under arrest.
  final bool isArrested;

  /// True while an arrest warrant is currently queued.
  final bool isArrestPending;

  /// Seconds remaining for the queued arrest.
  final double? arrestRemainingSeconds;

  /// Tracks whether a wire tap has been installed for this resident.
  final bool hasWireTap;

  /// Notification marker state for completed investigation.
  final bool hasInvestigationCompletedMarker;

  /// Notification marker state for completed arrest.
  final bool hasArrestCompletedMarker;

  const Resident({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.sex,
    required this.age,
    required this.street,
    required this.district,
    required this.phoneNumber,
    required this.occupation,
    required this.riskScore,
    this.isInvestigated = false,
    this.isInvestigationPending = false,
    this.investigationRemainingSeconds,
    this.isArrested = false,
    this.isArrestPending = false,
    this.arrestRemainingSeconds,
    this.hasWireTap = false,
    this.hasInvestigationCompletedMarker = false,
    this.hasArrestCompletedMarker = false,
  });

  String get name => '$firstName $lastName';

  String get status => isArrested ? 'ARRESTED' : 'FREE';

  bool get hasCompletedActionMarker =>
      hasInvestigationCompletedMarker || hasArrestCompletedMarker;

  Resident copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? sex,
    int? age,
    String? street,
    String? district,
    String? phoneNumber,
    String? occupation,
    double? riskScore,
    bool? isInvestigated,
    bool? isInvestigationPending,
    double? investigationRemainingSeconds,
    bool clearInvestigationRemainingSeconds = false,
    bool? isArrested,
    bool? isArrestPending,
    double? arrestRemainingSeconds,
    bool clearArrestRemainingSeconds = false,
    bool? hasWireTap,
    bool? hasInvestigationCompletedMarker,
    bool? hasArrestCompletedMarker,
  }) {
    return Resident(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      street: street ?? this.street,
      district: district ?? this.district,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      riskScore: riskScore ?? this.riskScore,
      isInvestigated: isInvestigated ?? this.isInvestigated,
      isInvestigationPending:
          isInvestigationPending ?? this.isInvestigationPending,
      investigationRemainingSeconds: clearInvestigationRemainingSeconds
          ? null
          : investigationRemainingSeconds ?? this.investigationRemainingSeconds,
      isArrested: isArrested ?? this.isArrested,
      isArrestPending: isArrestPending ?? this.isArrestPending,
      arrestRemainingSeconds: clearArrestRemainingSeconds
          ? null
          : arrestRemainingSeconds ?? this.arrestRemainingSeconds,
      hasWireTap: hasWireTap ?? this.hasWireTap,
      hasInvestigationCompletedMarker:
          hasInvestigationCompletedMarker ??
          this.hasInvestigationCompletedMarker,
      hasArrestCompletedMarker:
          hasArrestCompletedMarker ?? this.hasArrestCompletedMarker,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    sex,
    age,
    street,
    district,
    phoneNumber,
    occupation,
    riskScore,
    isInvestigated,
    isInvestigationPending,
    investigationRemainingSeconds,
    isArrested,
    isArrestPending,
    arrestRemainingSeconds,
    hasWireTap,
    hasInvestigationCompletedMarker,
    hasArrestCompletedMarker,
  ];

  /// Returns the risk score with the daily intelligence modifier applied.
  /// The base [riskScore] is never mutated — this is a read-only calculation.
  double effectiveRiskScore(IntelligenceReport? report) {
    if (report == null) return riskScore;
    var effective = riskScore;
    for (final modifier in report.modifiers) {
      final residentValue = switch (modifier.category) {
        'ageGroup' => _ageGroup,
        'occupation' => occupation,
        'district' => district,
        _ => null,
      };
      if (residentValue?.toLowerCase() == modifier.value.toLowerCase()) {
        effective += Consts.intelligenceRiskModifier;
      }
    }
    return effective.clamp(Consts.minThreatLevel, Consts.maxThreatLevel);
  }

  String get _ageGroup {
    if (age <= 29) return '18-29';
    if (age <= 39) return '30-39';
    if (age <= 64) return '40-64';
    return '65+';
  }
}
