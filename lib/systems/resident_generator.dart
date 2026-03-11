import 'dart:math';

import '../consts.dart';
import '../models/resident.dart';

class ResidentGenerator {
  static final Random _random = Random();

  static const List<String> _firstNames = [
    'Ari',
    'Mika',
    'Nora',
    'Rami',
    'Lena',
    'Tomas',
    'Nadia',
    'Dani',
    'Selam',
    'Iris',
  ];
  static const List<String> _lastNames = [
    'Khan',
    'Miller',
    'Santos',
    'Abebe',
    'Park',
    'Ivanov',
    'Nasser',
    'Ortiz',
    'Mensah',
    'Dubois',
  ];
  static const List<String> _sexes = ['Male', 'Female'];
  static const List<String> _occupations = [
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
  static const List<String> _streets = [
    'Oak Street',
    'Maple Avenue',
    'River Road',
    'Sunset Lane',
    'Central Boulevard',
    'Harbor Street',
    'Market Street',
    'Hillcrest Road',
  ];
  static const List<String> _districts = [
    'North District',
    'South District',
    'East District',
    'West District',
    'Central District',
  ];

  static List<Resident> generateDailyResidents(int count) {
    List<Resident> residents = [];
    for (int i = 0; i < count; i++) {
      final id =
          'ID-${_random.nextInt(Consts.residentIdRange) + Consts.residentIdBase}';

      final riskScore = _random.nextDouble() < Consts.generatedHighRiskChance
          ? Consts.generatedHighRiskMin +
                _random.nextDouble() * Consts.generatedHighRiskRange
          : _random.nextDouble() * Consts.generatedLowRiskMax;

      final name =
          '${_firstNames[_random.nextInt(_firstNames.length)]} ${_lastNames[_random.nextInt(_lastNames.length)]}';
      final sex = _sexes[_random.nextInt(_sexes.length)];
      final age = 18 + _random.nextInt(53);
      final street = _streets[_random.nextInt(_streets.length)];
      final district = _districts[_random.nextInt(_districts.length)];
      final phoneNumber =
          '+1-555-${_random.nextInt(900) + 100}-${_random.nextInt(9000) + 1000}';

      residents.add(
        Resident(
          id: id,
          name: name,
          sex: sex,
          age: age,
          street: street,
          district: district,
          phoneNumber: phoneNumber,
          occupation: _occupations[_random.nextInt(_occupations.length)],
          riskScore: riskScore,
        ),
      );
    }
    return residents;
  }
}
