import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:bigbrother/config.dart';

enum GameState { welcome, paused, playing }

class BigBrotherGame extends FlameGame {
	late GameState _state;

	BigBrotherGame() : super(
		camera: CameraComponent.withFixedResolution(
			width: GAME_WIDTH,
			height: GAME_HEIGHT,
		),
	);
	
	@override
	Future onLoad() async {
		camera.viewfinder.anchor = Anchor.topLeft;
		state = GameState.welcome;
		paused = true;
	}
	
	set state(GameState state) {
		_state = state;
		switch (_state) {
			case GameState.welcome:
			case GameState.paused:
				overlays.add(state.name);
			case GameState.playing:
				overlays.remove(GameState.welcome.name);
				overlays.remove(GameState.paused.name);
		}
	}
}

