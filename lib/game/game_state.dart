import 'package:flutter/foundation.dart';
import '../models/citizen.dart';
import '../systems/citizen_generator.dart';

/// Represents the global state of the game.
class GameState extends ChangeNotifier {
  int currentDay = 1;
  double terroristThreat = 0.0; // 0.0 to 100.0
  int detaineeCount = 0;
  int investigationCount = 0;
  double _remainingTimeInDay = 60.0; // 60 seconds per day, placeholder

  List<Citizen> todayCitizens = [];

  GameState() {
    _startNewDay();
  }

  int get remainingTimeInDay => _remainingTimeInDay.ceil();

  void _startNewDay() {
    _remainingTimeInDay = 60.0;
    todayCitizens = CitizenGenerator.generateDailyCitizens(30);
    notifyListeners();
  }

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
      // End of day condition
      currentDay++;
      _startNewDay();
    }

    notifyListeners();
  }

  /// Action: Detain a citizen.
  void detainCitizen(Citizen citizen) {
    detaineeCount++;
    todayCitizens.remove(citizen);

    // Apply threat rules on detaining
    if (citizen.riskScore > 60) {
      terroristThreat = (terroristThreat - 10.0).clamp(0.0, 100.0);
    } else if (citizen.riskScore < 40) {
      terroristThreat = (terroristThreat + 10.0).clamp(0.0, 100.0);
    }

    notifyListeners();
  }

  /// Action: Investigate a citizen.
  void investigateCitizen(Citizen citizen) {
    if (!citizen.isInvestigated) {
      citizen.isInvestigated = true;
    }

    investigationCount++;
    notifyListeners();
  }
}
