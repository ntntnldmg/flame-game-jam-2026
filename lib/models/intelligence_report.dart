import 'package:equatable/equatable.dart';

/// A daily intelligence briefing claiming a demographic has links to terrorism.
/// Causes a temporary +15 effective risk modifier on matching citizens for the day.
class IntelligenceReport extends Equatable {
  final int day;

  /// One of: 'ageGroup', 'occupation', 'religion', 'ethnicity'
  final String focusCategory;

  /// The specific value within that category, e.g. 'Teacher' or 'Muslim'
  final String focusValue;

  final String narrativeText;

  const IntelligenceReport({
    required this.day,
    required this.focusCategory,
    required this.focusValue,
    required this.narrativeText,
  });

  @override
  List<Object?> get props => [day, focusCategory, focusValue, narrativeText];
}
