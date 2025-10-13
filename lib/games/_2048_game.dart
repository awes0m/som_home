import 'dart:math';
import 'package:flutter/material.dart';

class Game2048 extends StatefulWidget {
  const Game2048({super.key});

  @override
  State<Game2048> createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  late List<List<int>> board;
  int score = 0;
  bool gameOver = false;
  bool gameWon = false;
  final int boardSize = 4;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));
    score = 0;
    gameOver = false;
    gameWon = false;
    _generateNewTile();
    _generateNewTile();
    setState(() {});
  }

  void _generateNewTile() {
    List<Point<int>> emptyCells = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == 0) {
          emptyCells.add(Point(i, j));
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      final random = Random();
      final int index = random.nextInt(emptyCells.length);
      final Point<int> cell = emptyCells[index];
      board[cell.x][cell.y] = random.nextDouble() < 0.9 ? 2 : 4;
    } else {
      _checkGameOver();
    }
  }

  void _checkGameOver() {
    if (board.any((row) => row.any((tile) => tile == 0))) {
      return; // There are empty cells, not game over
    }
    // Check for possible merges
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (j < boardSize - 1 && board[i][j] == board[i][j + 1]) {
          return; // Can merge right
        }
        if (i < boardSize - 1 && board[i][j] == board[i + 1][j]) {
          return; // Can merge down
        }
      }
    }
    setState(() {
      gameOver = true;
    });
  }

  void _checkGameWon() {
    if (board.any((row) => row.any((tile) => tile == 2048))) {
      setState(() {
        gameWon = true;
      });
    }
  }

  List<List<int>> _rotateBoard(List<List<int>> currentBoard) {
    List<List<int>> newBoard = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => 0),
    );
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        newBoard[j][boardSize - 1 - i] = currentBoard[i][j];
      }
    }
    return newBoard;
  }

  List<List<int>> _flipBoard(List<List<int>> currentBoard) {
    List<List<int>> newBoard = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => 0),
    );
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        newBoard[i][boardSize - 1 - j] = currentBoard[i][j];
      }
    }
    return newBoard;
  }

  bool _move(List<List<int>> currentBoard) {
    bool moved = false;
    for (int i = 0; i < boardSize; i++) {
      List<int> row = currentBoard[i].where((tile) => tile != 0).toList();
      List<int> newRow = [];
      for (int j = 0; j < row.length; j++) {
        if (j + 1 < row.length && row[j] == row[j + 1]) {
          newRow.add(row[j] * 2);
          score += row[j] * 2;
          j++;
          moved = true;
        } else {
          newRow.add(row[j]);
        }
      }
      while (newRow.length < boardSize) {
        newRow.add(0);
      }
      for (int j = 0; j < boardSize; j++) {
        if (currentBoard[i][j] != newRow[j]) {
          moved = true;
        }
        currentBoard[i][j] = newRow[j];
      }
    }
    return moved;
  }

  void _handleSwipe(DragEndDetails details) {
    if (gameOver || gameWon) return;

    bool moved = false;

    final double vx = details.velocity.pixelsPerSecond.dx;
    final double vy = details.velocity.pixelsPerSecond.dy;

    if (vy.abs() > vx.abs()) {
      if (vy < 0) {
        // Swiped up
        board = _rotateBoard(_rotateBoard(_rotateBoard(board)));
        moved = _move(board);
        board = _rotateBoard(board);
      } else {
        // Swiped down
        board = _rotateBoard(board);
        moved = _move(board);
        board = _rotateBoard(_rotateBoard(_rotateBoard(board)));
      }
    } else {
      if (vx < 0) {
        // Swiped left
        moved = _move(board);
      } else if (vx > 0) {
        // Swiped right
        board = _flipBoard(board);
        moved = _move(board);
        board = _flipBoard(board);
      }
    }

    if (moved) {
      _generateNewTile();
      _checkGameWon();
      _checkGameOver();
      setState(() {});
    }
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey.shade300;
      case 2:
        return Colors.orange.shade100;
      case 4:
        return Colors.orange.shade200;
      case 8:
        return Colors.orange.shade300;
      case 16:
        return Colors.orange.shade400;
      case 32:
        return Colors.orange.shade500;
      case 64:
        return Colors.orange.shade600;
      case 128:
        return Colors.yellow.shade300;
      case 256:
        return Colors.yellow.shade400;
      case 512:
        return Colors.yellow.shade500;
      case 1024:
        return Colors.yellow.shade600;
      case 2048:
        return Colors.yellow.shade700;
      default:
        return Colors.black;
    }
  }

  Color _getTileTextColor(int value) {
    if (value <= 4) {
      return Colors.grey.shade800;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSide = constraints.biggest.shortestSide.clamp(
          260.0,
          520.0,
        );
        final EdgeInsets contentPadding = constraints.maxWidth < 700
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 24);

        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          padding: contentPadding,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '2048',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: $score',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  if (gameWon) _buildBanner('You Win!', Colors.green),
                  if (gameOver) _buildBanner('Game Over!', Colors.red),
                  GestureDetector(
                    onVerticalDragEnd: _handleSwipe,
                    onHorizontalDragEnd: _handleSwipe,
                    child: Container(
                      width: boardSide,
                      height: boardSide,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: boardSize,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: boardSize * boardSize,
                        itemBuilder: (context, index) {
                          final int row = index ~/ boardSize;
                          final int col = index % boardSize;
                          final int value = board[row][col];
                          return Container(
                            decoration: BoxDecoration(
                              color: _getTileColor(value),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                value == 0 ? '' : '$value',
                                style: TextStyle(
                                  fontSize: boardSide / 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getTileTextColor(value),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Game'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(String message, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _startGame,
            style: FilledButton.styleFrom(backgroundColor: Colors.white10),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
