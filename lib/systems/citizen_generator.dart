import 'dart:math';

import '../consts.dart';
import '../models/citizen.dart';

class CitizenGenerator {
  static final Random _random = Random();

  static final List<String> _ageGroups = [
    '18-25',
    '26-35',
    '36-45',
    '46-60',
    '60+',
  ];
  static final List<String> _occupations = [
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
  ];
  static final List<String> _religions = [
    'Agnostic',
    'Christian',
    'Muslim',
    'Buddhist',
    'Hindu',
    'Atheist',
    'Other',
  ];
  static final List<String> _ethnicities = [
    'Caucasian',
    'Asian',
    'Hispanic',
    'African',
    'Middle Eastern',
    'Mixed',
  ];

  static List<Citizen> generateDailyCitizens(int count) {
    List<Citizen> citizens = [];
    for (int i = 0; i < count; i++) {
      String idNumber =
          'ID-${_random.nextInt(Consts.citizenIdRange) + Consts.citizenIdBase}';

      // Risk score: most are low risk (0-30), some high risk (70-100)
      double riskScore;
      if (_random.nextDouble() < Consts.generatedHighRiskChance) {
        // 15% chance of high risk
        riskScore =
            Consts.generatedHighRiskMin +
            _random.nextDouble() * Consts.generatedHighRiskRange;
      } else {
        riskScore = _random.nextDouble() * Consts.generatedLowRiskMax;
      }

      citizens.add(
        Citizen(
          idNumber: idNumber,
          ageGroup: _ageGroups[_random.nextInt(_ageGroups.length)],
          occupation: _occupations[_random.nextInt(_occupations.length)],
          religion: _religions[_random.nextInt(_religions.length)],
          ethnicity: _ethnicities[_random.nextInt(_ethnicities.length)],
          riskScore: riskScore,
        ),
      );
    }
    return citizens;
  }
}
