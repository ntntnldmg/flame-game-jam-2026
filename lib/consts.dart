import 'dart:ui' show Color;

/// Centralised colour palette for the entire application.
class AppColors {
  AppColors._();

  /// Primary teal/cyan used for UI chrome, rings, and labels.
  static const Color green = Color(0xff6eb5bb);

  /// Bright blueish-white used for highlights and progress arcs.
  static const Color bluishWhite = Color(0xffceecf8);

  /// Accent red used for threats, warnings, and danger states.
  static const Color red = Color(0xffd73766);

  /// Semi-transparent teal used for hover / selected-row backgrounds.
  static const Color hoverBackground = Color(0x4d6eb5bb);

  /// Semi-transparent blue used for breaking-news overlay backgrounds.
  static const Color breakingNewsBackground = Color(0x796eb5e8);

  /// Dark fill used inside the day-counter circle.
  static const Color circleFill = Color(0xFF0C2A2A);
}

class Consts {
  // --- Core progression ---
  static const double dayDuration = 50.0;
  static const double minThreatLevel = 0.0;
  static const double maxThreatLevel = 100.0;

  /// Threat starts at 15% and must reach 100% in exactly 2 days of passive play.
  ///
  /// That is 85% over 2 × [dayDuration] seconds.
  static const double threatRatePerSecond = 85.0 / (dayDuration * 2);

  /// The initial terrorist threat value when the game starts.
  static const double initialThreatLevel = 15.0;

  // --- Resident generation ---
  static const int residentsPerDay = 30;
  static const int residentIdBase = 10000;
  static const int residentIdRange = 90000;
  static const double generatedHighRiskChance = 0.15;
  static const double generatedHighRiskMin = 70.0;
  static const double generatedHighRiskRange = 30.0;
  static const double generatedLowRiskMax = 30.0;

  // --- Player action impact ---
  static const double arrestGoodThreshold = 60.0;
  static const double arrestBadThreshold = 40.0;
  static const double arrestThreatDelta = 10.0;
  static const double threatWarningLevel = 80.0;

  // --- Threat presentation cadence ---
  static const int threatPauseMinSeconds = 3;
  static const int threatPauseMaxSeconds = 8;
  static const int threatDisplayAnimationMs = 800;

  // --- Action workflow timings (seconds) ---
  static const int investigationDelayMinSeconds = 90;
  static const int investigationDelayMaxSeconds = 120;
  static const int arrestDelayMinSeconds = 45;
  static const int arrestDelayMaxSeconds = 60;

  // --- Daily action caps ---
  static const int maxInvestigationsPerDay = 15;
  static const int maxArrestsPerDay = 20;
  static const int maxWireTapsPerDay = 7;

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
  static const double highRiskPressurePerResidentPerSecond = 0.05;

  // --- CCTV surveillance event ---
  static const double cctvMinIntervalSeconds = 25.0;
  static const double cctvMaxIntervalSeconds = 40.0;

  /// Delay before the target face turns red after the overlay opens.
  static const double cctvInitialScanSeconds = 0.9;

  /// Click window in seconds once a target face turns red.
  static const double cctvClickWindowSeconds = 2.0;
  static const int cctvFaceCount = 15;
  static const double cctvSuccessThreatDelta = 5.0;
  static const double cctvFailureThreatDelta = 5.0;
}
