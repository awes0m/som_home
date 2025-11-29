import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../audio/audio.dart';
import '../../game_intro/game_intro.dart';
import '../game.dart';

class Game extends StatelessWidget {
  const Game({super.key});

  static PageRoute<void> route() {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => const Game(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final audioController = context.read<AudioController>();
    final gameBloc = context.read<GameBloc>();
    
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GameWidget.controlled(
            loadingBuilder: (context) => const GameBackground(),
            backgroundBuilder: (context) => const GameBackground(),
            gameFactory: () => SuperDashGame(
              gameBloc: gameBloc,
              audioController: audioController,
            ),
            overlayBuilderMap: {
              'tapToJump': (context, game) => const TapToJumpOverlay(),
            },
            initialActiveOverlays: const ['tapToJump'],
          ),
          const Positioned(
            top: 12,
            child: ScoreLabel(),
          ),
          const Positioned(
            bottom: 12,
            child: SafeArea(child: AudioButton()),
          ),
        ],
      ),
    );
  }
}
