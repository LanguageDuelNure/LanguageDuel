import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'game_views/searching_view.dart';
import 'game_views/game_view.dart';
import 'game_views/result_view.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameService>(
      builder: (context, game, _) {
        return switch (game.status) {
          GameStatus.idle => const SizedBox.shrink(),
          GameStatus.searching => const SearchingView(),
          GameStatus.inGame => game.gameState == null
              ? const SearchingView()
              : GameView(state: game.gameState!),
          GameStatus.finished => game.gameResult == null
              ? const SearchingView()
              : ResultView(result: game.gameResult!),
        };
      },
    );
  }
}