import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_typography.dart';
import '../audio/audio_settings.dart';
import '../consts.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';
import 'exposition_screen.dart';
import 'game_screen.dart';

/// The introduction screen shown when the app starts.
class IntroScreen extends StatefulWidget {
  final bool playShortOpeningTrack;

  const IntroScreen({super.key, this.playShortOpeningTrack = false});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

enum _IntroPhase { soundPrompt, emptyLeadIn, credits, titleOnly, menu }

class _IntroScreenState extends State<IntroScreen> {
  static int _openingMusicRequestId = 0;

  _IntroPhase _phase = _IntroPhase.soundPrompt;
  bool _soundEnabled = false;

  int _creditIndex = 0;
  double _creditOpacity = 0;
  Duration _creditFadeDuration = Duration.zero;
  dynamic _openingPlayer;
  String? _activeOpeningTrack;

  // First of 4 is the Flame icon, then text credit screens.
  final List<_CreditScreenData> _credits = const [
    _CreditScreenData.image('assets/images/flame_icon.png', imageWidth: 320),
    _CreditScreenData.text('Programming', 'Mussie Alemayehu'),
    _CreditScreenData.text('Writing', 'AChenM'),
    _CreditScreenData.text('Artwork, music, creative direction', 'NTNTNLDMG'),
  ];

  @override
  void initState() {
    super.initState();
    // First app startup asks for interaction to unlock browser audio.
    if (AudioSettings.hasPreference) {
      _soundEnabled = AudioSettings.isEnabled;
      _phase = _IntroPhase.menu;
      if (_soundEnabled) {
        _startOpeningMusic();
      }
    }
  }

  Future<void> _startOpeningMusic({bool forceShortTrack = false}) async {
    final trackName = (forceShortTrack || widget.playShortOpeningTrack)
        ? 'opening_short.ogg'
        : 'opening.ogg';
    if (_activeOpeningTrack == trackName) return;

    final requestId = ++_openingMusicRequestId;

    Future<void> playOnce() async {
      try {
        await _openingPlayer?.stop();
      } catch (_) {}
      _openingPlayer = null;
      await FlameAudio.bgm.stop();
      _openingPlayer = await FlameAudio.play(trackName);
    }

    try {
      await playOnce();
      if (!mounted || requestId != _openingMusicRequestId || !_soundEnabled) {
        return;
      }
      _activeOpeningTrack = trackName;
    } catch (error) {
      if (!mounted || requestId != _openingMusicRequestId || !_soundEnabled) {
        return;
      }
      // Common on web during route transitions when play() is interrupted.
      if (error.toString().contains('AbortError')) {
        await Future.delayed(const Duration(milliseconds: 220));
        if (!mounted || requestId != _openingMusicRequestId || !_soundEnabled) {
          return;
        }
        try {
          await playOnce();
          _activeOpeningTrack = trackName;
          return;
        } catch (_) {
          // Fall through to generic handler below.
        }
      }
      // Unsupported codec or other failure; continue without music.
      _soundEnabled = false;
      AudioSettings.setEnabled(false);
      debugPrint('Opening music unavailable: $error');
    }
  }

  Future<void> _stopOpeningMusic() async {
    _openingMusicRequestId++;
    _activeOpeningTrack = null;
    try {
      await _openingPlayer?.stop();
    } catch (_) {}
    _openingPlayer = null;
    await FlameAudio.bgm.stop();
  }

  Future<void> _beginOpeningSequence({required bool playOpeningCredits}) async {
    _soundEnabled = true;
    AudioSettings.setEnabled(true);

    if (!playOpeningCredits) {
      _setPhase(_IntroPhase.menu);
      await _startOpeningMusic(forceShortTrack: true);
      return;
    }

    _setPhase(_IntroPhase.emptyLeadIn);
    await Future.delayed(const Duration(milliseconds: 580));

    if (!mounted) return;
    await _startOpeningMusic();

    _setPhase(_IntroPhase.credits);

    for (int i = 0; i < _credits.length; i++) {
      if (!mounted) return;
      setState(() {
        _creditIndex = i;
        _creditOpacity = 0;
        _creditFadeDuration = Duration.zero;
      });

      await Future.delayed(Duration.zero);
      if (!mounted) return;
      setState(() {
        _creditFadeDuration = const Duration(milliseconds: 420);
        _creditOpacity = 1;
      });

      await Future.delayed(const Duration(milliseconds: 420));
      await Future.delayed(const Duration(milliseconds: 1660));
      if (!mounted) return;
      setState(() {
        _creditFadeDuration = const Duration(milliseconds: 500);
        _creditOpacity = 0;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      await Future.delayed(const Duration(milliseconds: 458));
    }

    if (!mounted) return;
    _setPhase(_IntroPhase.titleOnly);
    await Future.delayed(const Duration(milliseconds: 3038));
    if (!mounted) return;
    _setPhase(_IntroPhase.menu);
  }

  void _setPhase(_IntroPhase value) {
    if (!mounted) return;
    setState(() => _phase = value);
  }

  Future<void> _openSettings() async {
    bool tempSoundEnabled = _soundEnabled;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('SETTINGS'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Audio'),
                  Switch(
                    value: tempSoundEnabled,
                    onChanged: (value) {
                      setDialogState(() => tempSoundEnabled = value);
                    },
                    activeThumbColor: AppColors.green,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('APPLY'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) return;

    setState(() {
      _soundEnabled = tempSoundEnabled;
    });
    AudioSettings.setEnabled(tempSoundEnabled);

    if (_soundEnabled) {
      await _startOpeningMusic();
    } else {
      await _stopOpeningMusic();
    }
  }

  @override
  void dispose() {
    _stopOpeningMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: BlocBuilder<GameCubit, GameState>(
        buildWhen: (previous, current) =>
            previous.hasStartedGame != current.hasStartedGame,
        builder: (context, state) {
          if (_phase == _IntroPhase.soundPrompt) {
            return _SoundPrompt(
              onSelect: (playOpeningCredits) =>
                  _beginOpeningSequence(playOpeningCredits: playOpeningCredits),
            );
          }

          if (_phase == _IntroPhase.emptyLeadIn) {
            return const SizedBox.expand();
          }

          if (_phase == _IntroPhase.credits) {
            final credit = _credits[_creditIndex];
            return Center(
              child: AnimatedOpacity(
                opacity: _creditOpacity,
                duration: _creditFadeDuration,
                curve: Curves.linear,
                child: credit.isImage
                    ? Image.asset(
                        credit.imagePath!,
                        width: credit.imageWidth,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            credit.title!,
                            style: AppTypography.mono(
                              color: AppColors.textPrimary,
                              fontSize: 42,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            credit.subtitle!,
                            style: AppTypography.mono(
                              color: AppColors.textPrimary,
                              fontSize: 52,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              height: (_creditIndex == 3) ? 0.5 : 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            );
          }

          final showMenu = _phase == _IntroPhase.menu;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: min(800, MediaQuery.of(context).size.width * 0.8),
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),

                SizedBox(
                  height: 350,
                  child: Column(
                    children: showMenu
                        ? [
                            const SizedBox(height: 90),
                            if (state.hasStartedGame)
                              _MenuButton(
                                label: 'Continue',
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const GameScreen(),
                                    ),
                                  );
                                },
                              ),
                            if (state.hasStartedGame)
                              const SizedBox(height: 30),
                            _MenuButton(
                              label: 'New game',
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ExpositionScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 30),
                            _MenuButton(
                              label: 'Settings',
                              onPressed: _openSettings,
                            ),
                          ]
                        : [Container()],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SoundPrompt extends StatelessWidget {
  final ValueChanged<bool> onSelect;

  const _SoundPrompt({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.black,
          border: Border.all(color: AppColors.green, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Play opening credits?',
              style: AppTypography.mono(
                color: AppColors.textPrimary,
                fontSize: 32,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MenuButton(label: 'Yes', onPressed: () => onSelect(true)),
                const SizedBox(width: 16),
                _MenuButton(label: 'No', onPressed: () => onSelect(false)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: AppTypography.mono(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _CreditScreenData {
  final String? title;
  final String? subtitle;
  final String? imagePath;
  final double imageWidth;

  const _CreditScreenData.text(this.title, this.subtitle)
    : imagePath = null,
      imageWidth = 0;

  const _CreditScreenData.image(this.imagePath, {required this.imageWidth})
    : title = null,
      subtitle = null;

  bool get isImage => imagePath != null;
}
