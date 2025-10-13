import 'package:flutter/material.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String?> board = List.filled(9, null);
  String current = 'X';
  String? winner;

  void _tap(int i) {
    if (board[i] != null || winner != null) return;
    setState(() {
      board[i] = current;
      winner = _checkWinner();
      if (winner == null) {
        current = current == 'X' ? 'O' : 'X';
      }
    });
  }

  String? _checkWinner() {
    const wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final w in wins) {
      final a = board[w[0]];
      final b = board[w[1]];
      final c = board[w[2]];
      if (a != null && a == b && b == c) return a;
    }
    if (board.every((e) => e != null)) return 'Draw';
    return null;
  }

  void _reset() {
    setState(() {
      board = List.filled(9, null);
      current = 'X';
      winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSize = constraints.biggest.shortestSide.clamp(
          220.0,
          360.0,
        );
        final EdgeInsets contentPadding = constraints.maxWidth < 600
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 24);

        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          padding: contentPadding,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    winner == null
                        ? 'Turn: $current'
                        : (winner == 'Draw' ? 'Draw' : 'Winner: $winner'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, i) => InkWell(
                        onTap: () => _tap(i),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            color: Colors.grey.shade900,
                          ),
                          child: Center(
                            child: Text(
                              board[i] ?? '',
                              style: TextStyle(
                                color: board[i] == 'X'
                                    ? Colors.lightBlue
                                    : Colors.pinkAccent,
                                fontSize: boardSize / 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
