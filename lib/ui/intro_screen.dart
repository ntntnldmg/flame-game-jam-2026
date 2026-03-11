import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../audio/audio_settings.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';
import 'game_screen.dart';

/// The introduction screen shown when the app starts.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

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

  // First of 4 is the Flame icon, then text credit screens.
  final List<_CreditScreenData> _credits = const [
    _CreditScreenData.image('assets/images/flame_icon.png', imageWidth: 320),
    _CreditScreenData.text('Programming', 'Mussie Alemayehu'),
    _CreditScreenData.text('Artwork', 'Hopefully Someone'),
    _CreditScreenData.text('Music, writing, creative direction', 'NTNTNLDMG'),
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

  Future<void> _startOpeningMusic() async {
    final requestId = ++_openingMusicRequestId;
    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play('opening.ogg');
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
          await FlameAudio.bgm.stop();
          await FlameAudio.bgm.play('opening.ogg');
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

  Future<void> _beginOpeningSequence({required bool enableSound}) async {
    _soundEnabled = enableSound;
    AudioSettings.setEnabled(enableSound);

    _setPhase(_IntroPhase.emptyLeadIn);
    await Future.delayed(const Duration(milliseconds: 580));

    if (!mounted) return;
    if (_soundEnabled) {
      await _startOpeningMusic();
    }

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
                    activeThumbColor: Colors.greenAccent,
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
      await FlameAudio.bgm.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: BlocBuilder<GameCubit, GameState>(
        buildWhen: (previous, current) =>
            previous.hasStartedGame != current.hasStartedGame,
        builder: (context, state) {
          if (_phase == _IntroPhase.soundPrompt) {
            return _SoundPrompt(
              onSelect: (enable) => _beginOpeningSequence(enableSound: enable),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            credit.subtitle!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
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
                const Text(
                  'Terrorist Threat',
                  style: TextStyle(
                    fontSize: 84,
                    color: Colors.white,
                    letterSpacing: 3.2,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showMenu) ...[
                  const SizedBox(height: 60),
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
                  if (state.hasStartedGame) const SizedBox(height: 20),
                  _MenuButton(
                    label: 'New game',
                    onPressed: () {
                      context.read<GameCubit>().startNewSimulation();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _MenuButton(label: 'Settings', onPressed: _openSettings),
                ],
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
          color: Colors.black,
          border: Border.all(color: Colors.greenAccent, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enable Sound',
              style: TextStyle(
                color: Colors.white,
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
            style: const TextStyle(fontSize: 22, color: Colors.white),
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
