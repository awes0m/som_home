import 'package:flutter/material.dart';
import '../games/memory_match_game.dart';
import '../games/rock_paper_scissors_game.dart';
import '../games/tic_tac_toe_game.dart';
import '../games/_2048_game.dart';
import '../games/snake_game.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String? _selectedGame;

  final List<GameInfo> _games = [
    GameInfo(
      id: 'snake',
      title: 'Snake',
      description: 'Classic snake game - eat the food and grow!',
      icon: Icons.grid_4x4,
      color: Colors.green,
    ),
    GameInfo(
      id: 'rps',
      title: 'Rock Paper Scissors',
      description: 'Play against the computer and test your luck!',
      icon: Icons.sports_martial_arts,
      color: Colors.blue,
    ),
    GameInfo(
      id: '2048',
      title: '2048',
      description: 'Combine tiles to reach the 2048 tile!',
      icon: Icons.insert_chart,
      color: Colors.teal,
    ),
    GameInfo(
      id: 'tictactoe',
      title: 'Tic-Tac-Toe',
      description: 'Classic X and O game',
      icon: Icons.grid_on,
      color: Colors.purple,
    ),
    GameInfo(
      id: 'memory',
      title: 'Memory Match',
      description: 'Find matching pairs of cards',
      icon: Icons.casino,
      color: Colors.orange,
    ),
  ];

  Widget _buildGameWidget(String gameId) {
    switch (gameId) {
      case 'snake':
        return const SnakeGame();
      case 'rps':
        return const RockPaperScissorsGame();
      case '2048':
        return const Game2048();
      case 'tictactoe':
        return const TicTacToeGame();
      case 'memory':
        return const MemoryMatchGame();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedGame != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          title: Text(_games.firstWhere((g) => g.id == _selectedGame).title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _selectedGame = null),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double maxContentWidth = constraints.maxWidth > 900
                ? 900
                : constraints.maxWidth;
            final Color surfaceColor =
                Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.7);

            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: surfaceColor,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: _buildGameWidget(_selectedGame!),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.7),
            ),
            child: Row(
              children: [
                Text(
                  'Games',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Games Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 6 / 7.5,
              ),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                return _GameCard(
                  game: game,
                  onTap: () => setState(() => _selectedGame = game.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GameInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _GameCard extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;

  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                game.color.withValues(alpha: 0.7),
                game.color.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(game.icon, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
