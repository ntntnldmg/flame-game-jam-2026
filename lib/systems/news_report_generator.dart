import 'dart:math';

import '../game_script.dart';
import '../models/news_report.dart';

/// Generates atmospheric daily news bulletins.
///
/// Uses a shuffled bag so entries are exhausted before repetition begins.
class NewsReportGenerator {
  static final Random _random = Random();

  static List<int> _remainingIndices = [];

  /// Resets the shuffled bag so a new simulation starts fresh.
  static void resetCycle() {
    _remainingIndices = [];
  }

  static NewsReport generate(int day) {
    if (_remainingIndices.isEmpty) {
      _remainingIndices = List<int>.generate(
        GameScript.risklessInstructions.length,
        (i) => i,
      )..shuffle(_random);
    }

    final template =
        GameScript.risklessInstructions[_remainingIndices.removeLast()];
    final resolved = _resolvePlaceholders(template);

    return NewsReport(day: day, headline: 'CITY BULLETIN', body: resolved);
  }

  static String _resolvePlaceholders(String template) {
    final firstName = _pickAny([
      ...GameScript.maleFirstNames,
      ...GameScript.femaleFirstNames,
    ]);
    final lastName = _pickAny(GameScript.lastNames);
    final district = _pickAny(GameScript.districtNames);
    final age = (18 + _random.nextInt(53)).toString();

    return template
        .replaceAll(GameScript.firstNameStandin, firstName)
        .replaceAll(GameScript.lastNameStandin, lastName)
        .replaceAll(GameScript.districtStandin, district)
        .replaceAll(GameScript.ageStandin, age);
  }

  static String _pickAny(List<String> values) {
    return values[_random.nextInt(values.length)];
  }
}
