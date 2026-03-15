import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_typography.dart';
import '../../consts.dart';
import '../../game/game_cubit.dart';
import 'cctv_feed_game.dart';

class CctvScreenTile extends StatefulWidget {
  final int cameraNumber;
  final String imageAsset;
  final String timestamp;

  const CctvScreenTile({
    super.key,
    required this.cameraNumber,
    required this.imageAsset,
    required this.timestamp,
  });

  @override
  State<CctvScreenTile> createState() => _CctvScreenTileState();
}

class _CctvScreenTileState extends State<CctvScreenTile> {
  late final CctvFeedGame _feedGame;

  @override
  void initState() {
    super.initState();
    _feedGame = CctvFeedGame(gameCubit: context.read<GameCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.green)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          _feedGame.handleTap(details.localPosition);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(widget.imageAsset, fit: BoxFit.cover),
              Positioned.fill(child: GameWidget(game: _feedGame)),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.black.withAlpha(28),
                      AppColors.transparent,
                      AppColors.black.withAlpha(46),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withAlpha(140),
                    border: Border.all(color: AppColors.green),
                  ),
                  child: Text(
                    '${widget.cameraNumber}',
                    style: AppTypography.mono(
                      color: AppColors.green,
                      fontSize: 14,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 6,
                bottom: 4,
                child: Text(
                  widget.timestamp,
                  style: AppTypography.mono(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
