import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../games/chess.dart';
import '../games/memory_match_game.dart';
import '../games/rock_paper_scissors_game.dart';
import '../games/tic_tac_toe_game.dart';
import '../games/_2048_game.dart';
import '../games/snake_game.dart';
import '../core/utils/responsive.dart';
import '../core/providers/webview_provider.dart';

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
      icon: Icons.games_outlined,
      color: Colors.green,
    ),
    GameInfo(
      id: 'chess',
      title: 'chess♟️',
      description: 'classic chess',
      icon: Icons.abc,
      color: Colors.grey,
    ),
    GameInfo(
      id: 'rps',
      title: 'Rock Paper ✂️',
      description: 'Test your luck against the computer!',
      icon: Icons.sports_mma,
      color: Colors.blue,
    ),
    GameInfo(
      id: '2048',
      title: '2048',
      description: 'Combine tiles to reach the 2048 tile!',
      icon: Icons.filter_2,
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
    GameInfo(
      id: 'https://awes0m.github.io/tpdgame/',
      isLink: true,
      title: 'Prisoner\'s Dilemma',
      description: 'The classic prisoner\'s dilemma',
      icon: Icons.balance,
      color: Colors.blueAccent,
    ),
    GameInfo(
      id: 'https://awes0m.github.io/jsTgames/slider_game_flutter/#/',
      isLink: true,
      title: 'Slider',
      description: 'Slide the tiles to arrange them in order',
      icon: Icons.view_column,
      color: Colors.blueAccent,
    ),
    GameInfo(
      id: 'https://awes0m.github.io/jsTgames/',
      isLink: true,
      title: 'More Games',
      description: 'More games available online',
      icon: Icons.more,
      color: Colors.blueAccent,
    ),
  ];

  Widget _buildGameWidget(String gameId) {
    switch (gameId) {
      case 'snake':
        return const SnakeGame();
      case 'chess':
        return const ChessMainmenuScreen();
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
    final isMobile = ResponsiveHelper.isMobile(context);

    if (_selectedGame != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          title: Text(
            _games.firstWhere((g) => g.id == _selectedGame).title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                isMobile ? 18 : 20,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: isMobile ? 20 : 24),
            onPressed: () => setState(() => _selectedGame = null),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double maxContentWidth = ResponsiveHelper.getMaxContentWidth(
              context,
            );
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
                    padding: ResponsiveHelper.getResponsivePadding(context),
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
          // // Header
          // Container(
          //   padding: ResponsiveHelper.getResponsivePadding(context),
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).brightness == Brightness.dark
          //         ? Colors.black.withValues(alpha: 0.3)
          //         : Colors.white.withValues(alpha: 0.7),
          //   ),
          //   child: Row(
          //     children: [
          //       Text(
          //         'Games',
          //         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          //           fontWeight: FontWeight.bold,
          //           fontSize: ResponsiveHelper.getResponsiveFontSize(
          //             context,
          //             isMobile ? 28 : 32,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Games Grid
          Expanded(
            child: GridView.builder(
              padding: ResponsiveHelper.getResponsivePadding(context),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isMobile ? 200 : 300,
                crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  16,
                ),
                mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  16,
                ),
                childAspectRatio: isMobile ? 0.85 : 0.8,
              ),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                return _GameCard(
                  game: game,
                  isLink: game.isLink,
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
  final bool isLink;
  GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isLink = false,
  });
}

class _GameCard extends StatelessWidget {
  final GameInfo game;
  final VoidCallback onTap;
  final bool isLink;

  const _GameCard({
    required this.game,
    required this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (isLink)
            ? () {
                final webViewProvider = Provider.of<WebViewProvider>(
                  context,
                  listen: false,
                );
                webViewProvider.openUrl(game.id, title: game.title);
              }
            : onTap,
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
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(game.icon, size: isMobile ? 48 : 64, color: Colors.white),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 16),
                ),
                Text(
                  game.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isMobile ? 16 : 20,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 8),
                ),
                Text(
                  game.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      isMobile ? 12 : 14,
                    ),
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
