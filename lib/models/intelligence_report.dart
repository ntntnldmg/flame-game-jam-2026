import 'package:equatable/equatable.dart';

/// A daily combined briefing containing multiple instructions and risk modifiers.
class IntelligenceReport extends Equatable {
  final int day;
  final String narrativeText;
  final List<IntelligenceModifier> modifiers;

  const IntelligenceReport({
    required this.day,
    required this.narrativeText,
    required this.modifiers,
  });

  @override
  List<Object?> get props => [day, narrativeText, modifiers];
}

class IntelligenceModifier extends Equatable {
  /// One of: 'district', 'occupation', 'ageGroup'.
  final String category;
  final String value;

  const IntelligenceModifier({required this.category, required this.value});

  @override
  List<Object?> get props => [category, value];
}
