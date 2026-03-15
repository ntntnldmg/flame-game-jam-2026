import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_typography.dart';
import '../audio/audio_settings.dart';
import '../consts.dart';
import '../game/game_cubit.dart';
import '../game_script.dart';
import 'game_screen.dart';

class ExpositionScreen extends StatefulWidget {
  const ExpositionScreen({super.key});

  @override
  State<ExpositionScreen> createState() => _ExpositionScreenState();
}

class _ExpositionScreenState extends State<ExpositionScreen> {
  int _pageIndex = 0;
  int _audioRequestId = 0;
  String? _activeTrack;
  dynamic _activePlayer;

  static const List<String> _pageTracks = ['exposition.ogg', 'exposition2.ogg'];

  static const List<_ExpositionPageData> _pages = [
    _ExpositionPageData(
      body: GameScript.expositionFirstPart,
      imageAsset: 'assets/images/grafitti.png',
    ),
    _ExpositionPageData(
      body: GameScript.expositionSecondPart,
      imageAsset: 'assets/images/map.png',
    ),
  ];

  bool get _isLastPage => _pageIndex == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _syncPageAudio();
  }

  @override
  void dispose() {
    _stopExpositionAudio();
    super.dispose();
  }

  Future<void> _startPageTrack(String trackName) async {
    if (!AudioSettings.isEnabled) {
      _activeTrack = null;
      try {
        await _activePlayer?.stop();
      } catch (_) {}
      _activePlayer = null;
      await FlameAudio.bgm.stop();
      return;
    }
    if (_activeTrack == trackName) return;

    final requestId = ++_audioRequestId;

    Future<void> playOnce() async {
      try {
        await _activePlayer?.stop();
      } catch (_) {}
      _activePlayer = null;
      await FlameAudio.bgm.stop();
      _activePlayer = await FlameAudio.play(trackName);
    }

    try {
      await playOnce();
      if (!mounted || requestId != _audioRequestId) return;
      _activeTrack = trackName;
    } catch (error) {
      if (error.toString().contains('AbortError')) {
        await Future.delayed(const Duration(milliseconds: 220));
        if (!mounted || requestId != _audioRequestId) return;
        try {
          await playOnce();
          if (!mounted || requestId != _audioRequestId) return;
          _activeTrack = trackName;
          return;
        } catch (_) {
          // Fall through to generic handler below.
        }
      }
      debugPrint('Exposition audio unavailable: $error');
      _activeTrack = null;
    }
  }

  Future<void> _stopExpositionAudio() async {
    _audioRequestId++;
    _activeTrack = null;
    try {
      await _activePlayer?.stop();
    } catch (_) {}
    _activePlayer = null;
    await FlameAudio.bgm.stop();
  }

  void _syncPageAudio() {
    final track = _pageTracks[_pageIndex.clamp(0, _pageTracks.length - 1)];
    _startPageTrack(track);
  }

  Future<void> _startGame() async {
    await _stopExpositionAudio();
    if (!mounted) return;
    context.read<GameCubit>().startNewSimulation();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];

    return Scaffold(
      backgroundColor: AppColors.expositionBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.expositionGradientTop,
                      AppColors.expositionGradientBottom,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        border: Border.all(
                          color: AppColors.green.withAlpha(180),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.breakingNewsBackground,
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CLASSIFIED BRIEFING // ${GameScript.cityName.toUpperCase()}',
                            style: AppTypography.mono(
                              color: AppColors.green,
                              fontSize: 20,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(height: 2, color: AppColors.green),
                          const SizedBox(height: 26),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    page.body.trim(),
                                    style: AppTypography.mono(
                                      color: AppColors.textSecondary,
                                      fontSize: 22,
                                      letterSpacing: 0.6,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.asset(
                                      page.imageAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: List.generate(
                              _pages.length,
                              (index) => Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(right: 8),
                                color: index == _pageIndex
                                    ? AppColors.green
                                    : AppColors.textLowEmphasis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isLastPage) {
                                  _startGame();
                                  return;
                                }
                                setState(() => _pageIndex += 1);
                                _syncPageAudio();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                child: Text(
                                  _isLastPage ? 'BEGIN OPERATION' : 'NEXT',
                                  style: AppTypography.mono(
                                    fontSize: 18,
                                    letterSpacing: 1.6,
                                    fontWeight: FontWeight.w700,
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
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: TextButton(
                  onPressed: _startGame,
                  child: Text(
                    'SKIP EXPOSITION',
                    style: AppTypography.mono(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpositionPageData {
  final String body;
  final String imageAsset;

  const _ExpositionPageData({required this.body, required this.imageAsset});
}
