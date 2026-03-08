import 'package:flame/game.dart';
import 'game_cubit.dart';

/// The main game class extending FlameGame.
/// Handles the game loop and component management.
class BigBrotherGame extends FlameGame {
  final GameCubit gameCubit;

  BigBrotherGame(this.gameCubit);

  @override
  Future<void> onLoad() async {
    // Initialization logic goes here
    // e.g., loading assets, adding initial components
    await super.onLoad();
  }

  @override
  void update(double dt) {
    // Main game loop update
    super.update(dt);

    // Update game state
    gameCubit.tick(dt);
  }
}
