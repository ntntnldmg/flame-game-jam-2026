import 'package:equatable/equatable.dart';

/// A fabricated news bulletin shown at the start of each day to build
/// atmosphere before the intelligence briefing.
class NewsReport extends Equatable {
  final int day;
  final String headline;
  final String body;

  const NewsReport({
    required this.day,
    required this.headline,
    required this.body,
  });

  @override
  List<Object?> get props => [day, headline, body];
}
