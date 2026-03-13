import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'cctv_event_component.dart';
import 'game_cubit.dart';

/// The main game class extending FlameGame.
/// Handles the game loop and component management.
class BigBrotherGame extends FlameGame {
  final GameCubit gameCubit;

  BigBrotherGame(this.gameCubit);

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CCTVEventComponent(gameCubit));
  }

  @override
  void update(double dt) {
    // Main game loop update
    super.update(dt);

    // Guard against the cubit being closed during navigation transitions.
    if (!gameCubit.isClosed) {
      gameCubit.tick(dt);
    }
  }
}
