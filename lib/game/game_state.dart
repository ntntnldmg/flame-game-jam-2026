import 'package:flutter/foundation.dart';

/// Represents the global state of the game.
class GameState extends ChangeNotifier {
  int currentDay = 1;
  double terroristThreat = 0.0; // 0.0 to 100.0
  int detaineeCount = 0;
  int investigationCount = 0;
  double _remainingTimeInDay = 60.0; // 60 seconds per day, placeholder

  int get remainingTimeInDay => _remainingTimeInDay.ceil();

  /// Updates the time and threat based on delta time (dt).
  void updateTime(double dt) {
    if (terroristThreat >= 100.0 || _remainingTimeInDay <= 0) return;

    _remainingTimeInDay -= dt;
    terroristThreat += 1.0 * dt; // Threat increases 1% every second placeholder

    if (terroristThreat >= 100.0) {
      terroristThreat = 100.0;
      // TODO: Handle game over condition
    }

    if (_remainingTimeInDay <= 0) {
      _remainingTimeInDay = 0;
      // TODO: Handle end of day condition
    }

    notifyListeners();
  }

  /// Action: Detain a citizen.
  void detainCitizen() {
    detaineeCount++;
    notifyListeners();
  }

  /// Action: Investigate a citizen.
  void investigateCitizen() {
    investigationCount++;
    notifyListeners();
  }
}
