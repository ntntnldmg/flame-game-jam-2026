import 'dart:math';
import '../models/intelligence_report.dart';

/// Generates a random [IntelligenceReport] for the start of a new day.
class ReportGenerator {
  static final Random _random = Random();

  static const List<String> _categories = [
    'ageGroup',
    'occupation',
    'religion',
    'ethnicity',
  ];

  static const Map<String, List<String>> _values = {
    'ageGroup': ['18-25', '26-35', '36-45', '46-60', '60+'],
    'occupation': [
      'Student',
      'Engineer',
      'Doctor',
      'Teacher',
      'Unemployed',
      'Artist',
      'Mechanic',
      'Clerk',
      'Manager',
      'Catering',
    ],
    'religion': [
      'Agnostic',
      'Christian',
      'Muslim',
      'Buddhist',
      'Hindu',
      'Atheist',
      'Other',
    ],
    'ethnicity': [
      'Caucasian',
      'Asian',
      'Hispanic',
      'African',
      'Middle Eastern',
      'Mixed',
    ],
  };

  static IntelligenceReport generate(int day) {
    final category = _categories[_random.nextInt(_categories.length)];
    final values = _values[category]!;
    final value = values[_random.nextInt(values.length)];
    return IntelligenceReport(
      day: day,
      focusCategory: category,
      focusValue: value,
      narrativeText: _buildNarrative(category, value),
    );
  }

  static String _buildNarrative(String category, String value) {
    return switch (category) {
      'occupation' =>
        "Recent intelligence suggests an increased correlation between the "
            "occupation group '$value' and extremist affiliations. "
            "Exercise heightened scrutiny toward individuals in this category.",
      'religion' =>
        "Classified intercepts indicate that individuals identifying as "
            "'$value' show elevated risk patterns this operational cycle. "
            "Proceed with caution during any interactions.",
      'ageGroup' =>
        "Field reports point to a higher incidence of radicalization among "
            "citizens in the '$value' age bracket. "
            "Remain vigilant and document all anomalous behavior.",
      'ethnicity' =>
        "Threat analysis has flagged the '$value' demographic as a category "
            "of interest for this operational cycle. "
            "Monitor all individuals matching this classification closely.",
      _ =>
        "Intelligence report classified. Exercise heightened scrutiny toward "
            "the '$value' group during this cycle.",
    };
  }
}
