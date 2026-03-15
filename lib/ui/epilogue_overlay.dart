import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_typography.dart';
import '../audio/audio_settings.dart';
import '../consts.dart';
import '../game/game_cubit.dart';
import '../game_script.dart';

class EpilogueOverlay extends StatefulWidget {
  const EpilogueOverlay({super.key});

  @override
  State<EpilogueOverlay> createState() => _EpilogueOverlayState();
}

class _EpilogueOverlayState extends State<EpilogueOverlay> {
  static const Duration _briefingDuration = Duration(
    seconds: Consts.briefingDuration,
  );

  int _stage = 0;
  bool _playedEpilogueMusic = false;
  dynamic _epiloguePlayer;
  Timer? _briefingTimer;

  @override
  void dispose() {
    _briefingTimer?.cancel();
    _stopEpilogueAudio();
    super.dispose();
  }

  void _startBriefingCountdown() {
    _briefingTimer?.cancel();
    _briefingTimer = Timer(_briefingDuration, () {
      if (!mounted) return;
      context.read<GameCubit>().completeEpilogue();
    });
  }

  Future<void> _stopEpilogueAudio() async {
    try {
      await _epiloguePlayer?.stop();
    } catch (_) {}
    _epiloguePlayer = null;
  }

  Future<void> _playEpilogueMusicOnce() async {
    if (_playedEpilogueMusic) return;
    _playedEpilogueMusic = true;
    if (!AudioSettings.isEnabled) return;
    try {
      await FlameAudio.bgm.stop();
      _epiloguePlayer = await FlameAudio.play('epilogue.ogg');
    } catch (error) {
      debugPrint('Epilogue audio unavailable: $error');
      _epiloguePlayer = null;
    }
  }

  String _firstParagraph(String text) {
    final parts = text.trim().split('\n\n');
    return parts.isNotEmpty ? parts.first.trim() : text.trim();
  }

  String _remainingBody(String text) {
    final parts = text.trim().split('\n\n');
    if (parts.length <= 1) return text.trim();
    return parts.skip(1).join('\n\n').trim();
  }

  Widget _buildNewspaperStage() {
    final headline = GameScript.epilogueNewspaperHeading.toUpperCase();
    final lead = _firstParagraph(GameScript.epilogueNewspaperArticle);
    final body = _remainingBody(GameScript.epilogueNewspaperArticle);

    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: AppColors.appBackground,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Container(
            color: AppColors.newspaperPaper,
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
            child: Column(
              children: [
                //Container(height: 22, color: AppColors.newspaperAccent),
                const SizedBox(height: 14),
                Text(
                  GameScript.epilogueNewspaperName,
                  style: GoogleFonts.manufacturingConsent(
                    color: AppColors.newspaperInk,
                    fontSize: 96,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    height: 0.92,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.newspaperInk),
                      bottom: BorderSide(
                        color: AppColors.newspaperInk,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VOL. LXII ... No. 12,213',
                        style: GoogleFonts.noticiaText(
                          color: AppColors.newspaperInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '© 2064 The Mavenport Times Company',
                        style: GoogleFonts.noticiaText(
                          color: AppColors.newspaperInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'MAVENPORT, THURSDAY, 22 APRIL 2064',
                        style: GoogleFonts.noticiaText(
                          color: AppColors.newspaperInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '\$6.40',
                        style: GoogleFonts.noticiaText(
                          color: AppColors.newspaperInk,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  headline,
                  style: GoogleFonts.noticiaText(
                    color: AppColors.newspaperInk,
                    fontSize: 39,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 0.96,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/city.png'),
                            Text(
                              'AChenM for the Mavenport Times',
                              style: GoogleFonts.noticiaText(
                                color: AppColors.newspaperInk,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 26),
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: lead,
                                  style: GoogleFonts.noticiaText(
                                    color: AppColors.newspaperInk,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    height: 1.35,
                                  ),
                                ),
                                TextSpan(
                                  text: '\n\n$body',
                                  style: GoogleFonts.noticiaText(
                                    color: AppColors.newspaperInk,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    height: 1.36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _stage = 1);
                      _playEpilogueMusicOnce();
                      _startBriefingCountdown();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      child: Text(
                        'CONTINUE',
                        style: AppTypography.mono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBriefingStage() {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: AppColors.appBackground,
        child: Center(
          child: Container(
            width: 720,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.black,
              border: Border.all(color: AppColors.green, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLASSIFIED',
                  style: AppTypography.mono(
                    color: AppColors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(height: 2, color: AppColors.green),
                const SizedBox(height: 24),
                Text(
                  GameScript.epilogueBriefingHeading,
                  style: AppTypography.mono(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  GameScript.epilogueBriefingText.trim(),
                  style: AppTypography.mono(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                    letterSpacing: 0.5,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == 0) return _buildNewspaperStage();
    return _buildBriefingStage();
  }
}
