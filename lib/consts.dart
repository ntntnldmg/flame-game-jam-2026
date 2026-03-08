class Consts {
  static const dayDuration = 30.0;

  /// Threat starts at 15% and must reach 100% in exactly 2 days of passive play.
  ///
  /// That is 85% over 2 × [dayDuration] seconds.
  static const double threatRatePerSecond = 85.0 / (dayDuration * 2);

  /// The initial threat level for when the game starts
  static const initialThreatLevel = 15.0;
}
