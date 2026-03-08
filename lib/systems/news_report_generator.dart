import 'dart:math';

import '../models/news_report.dart';

/// Generates atmospheric daily news bulletins.
///
/// Uses a shuffled bag so entries are exhausted before repetition begins.
class NewsReportGenerator {
  static final Random _random = Random();

  static final List<_NewsTemplate> _templates = [
    const _NewsTemplate(
      headline: 'Night Curfew Extended After Blasts',
      body:
          'Authorities confirm another coordinated attack overnight. Security '
          'services say emergency checkpoints will remain active until further notice.',
    ),
    const _NewsTemplate(
      headline: 'Officials Warn Of Embedded Cells',
      body:
          'Officials warn that extremist cells may already be inside the city. '
          'Residents are urged to report unusual movement near transport hubs.',
    ),
    const _NewsTemplate(
      headline: 'Transit Routes Hit By Sudden Sabotage',
      body:
          'Multiple transport corridors were disrupted before dawn by what '
          'investigators called synchronized sabotage attempts.',
    ),
    const _NewsTemplate(
      headline: 'Security Presence Doubled Downtown',
      body:
          'Armored patrols and additional surveillance teams have been deployed '
          'across central districts following new threat intercepts.',
    ),
    const _NewsTemplate(
      headline: 'Emergency Broadcast Urges Vigilance',
      body:
          'Government channels issued a citywide alert, warning residents to '
          'avoid crowded venues and remain alert for suspicious behavior.',
    ),
    const _NewsTemplate(
      headline: 'Unverified Claims Fuel Public Anxiety',
      body:
          'Rumors of sleeper networks spread rapidly overnight, though officials '
          'say operational details remain classified.',
    ),
    const _NewsTemplate(
      headline: 'Industrial Zone Sealed Overnight',
      body:
          'A major industrial sector was temporarily locked down after a series '
          'of incidents linked to extremist logistics activity.',
    ),
    const _NewsTemplate(
      headline: 'Hospitals Report Surge In Casualties',
      body:
          'Medical centers entered contingency protocols after emergency teams '
          'responded to multiple late-night explosions.',
    ),
    const _NewsTemplate(
      headline: 'Cabinet Convenes Security Session',
      body:
          'Senior officials convened an emergency security session and signaled '
          'that further restrictions may be announced.',
    ),
    const _NewsTemplate(
      headline: 'Rail Authority Confirms Coordinated Threat',
      body:
          'Rail operators cited coordinated disruption attempts and warned of '
          'possible follow-up incidents over the coming cycle.',
    ),
    const _NewsTemplate(
      headline: 'Border Checkpoints Shift To High Alert',
      body:
          'Border and customs units have moved to high alert status after '
          'intelligence indicated cross-region extremist movement.',
    ),
    const _NewsTemplate(
      headline: 'Power Grid Incident Under Investigation',
      body:
          'Engineers restored service after a targeted infrastructure incident '
          'that authorities suspect was part of a broader operation.',
    ),
    const _NewsTemplate(
      headline: 'Schools Begin Day Under Security Protocols',
      body:
          'Education facilities reopened with reinforced screening as officials '
          'continue to assess a volatile threat environment.',
    ),
    const _NewsTemplate(
      headline: 'Market District Patrols Intensify',
      body:
          'Crowded market corridors are now under intensified patrol as command '
          'centers track multiple unresolved incident reports.',
    ),
    const _NewsTemplate(
      headline: 'Communications Blackout Briefly Enforced',
      body:
          'A short communications blackout was enacted overnight while security '
          'teams carried out coordinated search operations.',
    ),
    const _NewsTemplate(
      headline: 'Authorities Cite Elevated National Threat',
      body:
          'National authorities have raised the threat posture and asked local '
          'units to maintain maximum readiness.',
    ),
    const _NewsTemplate(
      headline: 'Witnesses Report Multiple Detonations',
      body:
          'Witnesses in separate districts reported near-simultaneous '
          'detonations as investigators work to establish links.',
    ),
    const _NewsTemplate(
      headline: 'Counterterror Units Conduct Night Raids',
      body:
          'Counterterror teams conducted overnight raids tied to suspected '
          'logistics nodes, with several sites still under review.',
    ),
    const _NewsTemplate(
      headline: 'City Services Move To Emergency Mode',
      body:
          'Critical services switched to emergency operations after officials '
          'flagged a sustained risk of repeat attacks.',
    ),
    const _NewsTemplate(
      headline: 'Security Cameras Capture Unknown Operatives',
      body:
          'Investigators are analyzing footage of unidentified operatives seen '
          'near key infrastructure shortly before last night incidents.',
    ),
  ];

  static List<int> _remainingIndices = [];

  static NewsReport generate(int day) {
    if (_remainingIndices.isEmpty) {
      _remainingIndices = List<int>.generate(_templates.length, (i) => i)
        ..shuffle(_random);
    }

    final index = _remainingIndices.removeLast();
    final template = _templates[index];

    return NewsReport(
      day: day,
      headline: template.headline,
      body: template.body,
    );
  }
}

class _NewsTemplate {
  final String headline;
  final String body;

  const _NewsTemplate({required this.headline, required this.body});
}
