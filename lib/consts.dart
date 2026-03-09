class Consts {
  // --- Core progression ---
  static const double dayDuration = 30.0;
  static const double minThreatLevel = 0.0;
  static const double maxThreatLevel = 100.0;

  /// Threat starts at 15% and must reach 100% in exactly 2 days of passive play.
  ///
  /// That is 85% over 2 × [dayDuration] seconds.
  static const double threatRatePerSecond = 85.0 / (dayDuration * 2);

  /// The initial threat level for when the game starts
  static const double initialThreatLevel = 15.0;

  // --- Citizen generation ---
  static const int citizensPerDay = 30;
  static const int citizenIdBase = 10000;
  static const int citizenIdRange = 90000;
  static const double generatedHighRiskChance = 0.15;
  static const double generatedHighRiskMin = 70.0;
  static const double generatedHighRiskRange = 30.0;
  static const double generatedLowRiskMax = 30.0;

  // --- Player action impact ---
  static const double detainGoodThreshold = 60.0;
  static const double detainBadThreshold = 40.0;
  static const double detainThreatDelta = 10.0;
  static const double threatWarningLevel = 80.0;

  // --- Intelligence report modifier ---
  static const double intelligenceRiskModifier = 15.0;

  // --- Tick cadence ---
  static const double stateEmitThresholdSeconds = 0.1;

  // --- Dynamic risk drift ---
  static const double riskDriftIntervalSeconds = 10.0;
  static const int riskDriftSampleSize = 3;
  static const double riskDriftStep = 5.0;
  static const double highRiskThreshold = 70.0;
  static const int highRiskCapMinCount = 1;
  static const double highRiskCapRatio = 0.10;
  static const double driftHighRiskReductionChance = 0.65;

  // --- Hidden systemic pressure (not shown in UI) ---
  static const double highRiskPressureCheckIntervalSeconds = 5.0;
  static const int highRiskPressureTriggerCount = 2;
  static const double highRiskPressureBasePerSecond = 0.118;
  static const double highRiskPressurePerCitizenPerSecond = 0.05;
}
