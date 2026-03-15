import 'dart:math';

import '../consts.dart';
import '../game_script.dart';
import '../models/resident.dart';

class ResidentGenerator {
  static final Random _random = Random();

  static const List<String> _maleFirstNames = GameScript.maleFirstNames;
  static const List<String> _femaleFirstNames = GameScript.femaleFirstNames;
  static const List<String> _lastNames = GameScript.lastNames;
  static const List<String> _sexes = ['Male', 'Female'];
  static const List<String> _occupations = GameScript.occupations;
  static const Map<String,List<String>> _streets = GameScript.streetNames;
  static const List<String> _districts = GameScript.districtNames;

  static List<Resident> generateDailyResidents(int count) {
    List<Resident> residents = [];
    for (int i = 0; i < count; i++) {
      final id =
          '${_random.nextInt(Consts.residentIdRange) + Consts.residentIdBase}';

      final riskScore = _random.nextDouble() < Consts.generatedHighRiskChance
          ? Consts.generatedHighRiskMin +
                _random.nextDouble() * Consts.generatedHighRiskRange
          : _random.nextDouble() * Consts.generatedLowRiskMax;

			final sex = _sexes[_random.nextInt(_sexes.length)];
			final firstName = (sex == 'Male') ?
				_maleFirstNames[_random.nextInt(_maleFirstNames.length)] :
				_femaleFirstNames[_random.nextInt(_femaleFirstNames.length)];
			final lastName = _lastNames[_random.nextInt(_lastNames.length)];
      final age = 18 + _random.nextInt(53);
      final district = _districts[_random.nextInt(_districts.length)];
      final street = _streets[district]![_random.nextInt(_streets[district]!.length)];
      final phoneNumber =
          '+000-${_random.nextInt(900) + 100}-${_random.nextInt(9000) + 1000}';

      residents.add(
        Resident(
          id: id,
          firstName: firstName,
          lastName: lastName,
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
    residents.sort((a,b) => a.lastName.compareTo(b.lastName));
    return residents;
  }
}
