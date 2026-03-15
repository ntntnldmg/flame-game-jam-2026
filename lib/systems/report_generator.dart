import 'dart:math';

import '../game_script.dart';
import '../models/intelligence_report.dart';

/// Generates a random [IntelligenceReport] for the start of a new day.
class ReportGenerator {
  static final Random _random = Random();

  static IntelligenceReport generate(int day) {
    final districtSelection = _selectDistrictInstruction();
    final occupationSelection = _selectOccupationInstruction();
    final ageGroupSelection = _selectAgeGroupInstruction();
    final risklessSelections = _selectRisklessInstructions(count: 2);

    final lines = <String>[
      districtSelection.instruction,
      occupationSelection.instruction,
      ageGroupSelection.instruction,
      ...risklessSelections,
    ]..shuffle(_random);

    final instructionsText = lines.map((line) => '- $line').join('\n\n');
    final narrativeText = day == 1
        ? '''
${GameScript.intelBriefing.trim()}

=====================================
FIRST INTEL REPORT INCOMING
=====================================

$instructionsText
'''
        : instructionsText;

    return IntelligenceReport(
      day: day,
      narrativeText: narrativeText,
      modifiers: [
        IntelligenceModifier(
          category: 'district',
          value: districtSelection.focusValue,
        ),
        IntelligenceModifier(
          category: 'occupation',
          value: occupationSelection.focusValue,
        ),
        IntelligenceModifier(
          category: 'ageGroup',
          value: ageGroupSelection.focusValue,
        ),
      ],
    );
  }

  static _IntelInstructionSelection _selectDistrictInstruction() {
    final template = _pickAny(GameScript.districtInstructions);
    final district = _pickAny(GameScript.districtNames);
    return _IntelInstructionSelection(
      focusValue: district,
      instruction: _resolvePlaceholders(
        template.replaceAll(GameScript.districtStandin, district),
      ),
    );
  }

  static _IntelInstructionSelection _selectOccupationInstruction() {
    final occupationKeys = GameScript.occupationInstructions.keys.toList();
    final occupation = _pickAny(occupationKeys);
    final template = _pickAny(GameScript.occupationInstructions[occupation]!);
    return _IntelInstructionSelection(
      focusValue: occupation,
      instruction: _resolvePlaceholders(template),
    );
  }

  static _IntelInstructionSelection _selectAgeGroupInstruction() {
    final ageGroups = GameScript.demographicsInstructions.keys.toList();
    final ageGroup = _pickAny(ageGroups);
    final template = _pickAny(GameScript.demographicsInstructions[ageGroup]!);
    return _IntelInstructionSelection(
      focusValue: ageGroup,
      instruction: _resolvePlaceholders(template),
    );
  }

  static List<String> _selectRisklessInstructions({required int count}) {
    final indices = List<int>.generate(
      GameScript.risklessInstructions.length,
      (i) => i,
    )..shuffle(_random);

    final selected = <String>[];
    for (var i = 0; i < count && i < indices.length; i++) {
      selected.add(
        _resolvePlaceholders(GameScript.risklessInstructions[indices[i]]),
      );
    }
    return selected;
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

class _IntelInstructionSelection {
  final String focusValue;
  final String instruction;

  const _IntelInstructionSelection({
    required this.focusValue,
    required this.instruction,
  });
}
