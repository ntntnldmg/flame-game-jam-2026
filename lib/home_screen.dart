//ignore_for_file: constant_identifier_names

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:bigbrother/config.dart';
import 'package:bigbrother/game.dart';

class HomeScreen extends StatelessWidget {
	final game = BigBrotherGame();
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Center(
					child: FittedBox(
						child: SizedBox(
							width: GAME_WIDTH,
							height: GAME_HEIGHT,
							child: GameWidget(
								game: game,
								overlayBuilderMap: {
									GameState.welcome.name: (context, game) {
										return Text('Welcome screen', style: TextStyle(color: Colors.white));
									},
									GameState.paused.name: (context, game) {
										return Text('Gameplay paused', style: TextStyle(color: Colors.white));
									},
								},
							),
						),
					),
				),
			),
		);
	}
}

