import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(15, 15);
  Direction direction = Direction.right;
  Direction? nextDirection;
  bool isPlaying = false;
  int score = 0;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _generateFood();
  }

  void _startGame() {
    snake = [const Point(10, 10)];
    direction = Direction.right;
    nextDirection = null;
    score = 0;
    isPlaying = true;
    _generateFood();

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _updateGame();
    });
  }

  void _updateGame() {
    if (!isPlaying) return;

    if (nextDirection != null) {
      direction = nextDirection!;
      nextDirection = null;
    }

    Point<int> newHead;
    switch (direction) {
      case Direction.up:
        newHead = Point(snake.first.x, snake.first.y - 1);
        break;
      case Direction.down:
        newHead = Point(snake.first.x, snake.first.y + 1);
        break;
      case Direction.left:
        newHead = Point(snake.first.x - 1, snake.first.y);
        break;
      case Direction.right:
        newHead = Point(snake.first.x + 1, snake.first.y);
        break;
    }

    // Check collision with walls
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      _gameOver();
      return;
    }

    // Check collision with self
    if (snake.contains(newHead)) {
      _gameOver();
      return;
    }

    setState(() {
      snake.insert(0, newHead);

      // Check if food is eaten
      if (newHead == food) {
        score += 10;
        _generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void _generateFood() {
    final random = Random();
    Point<int> newFood;
    do {
      newFood = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.contains(newFood));

    setState(() => food = newFood);
  }

  void _gameOver() {
    gameTimer?.cancel();
    setState(() => isPlaying = false);
  }

  void _changeDirection(Direction newDirection) {
    if (!isPlaying) return;

    // Prevent reversing
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }

    nextDirection = newDirection;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSize = constraints.biggest.shortestSide.clamp(
          240.0,
          480.0,
        );
        final EdgeInsets contentPadding = constraints.maxWidth < 600
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 24);

        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                _changeDirection(Direction.up);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                _changeDirection(Direction.down);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                _changeDirection(Direction.left);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                _changeDirection(Direction.right);
              }
            }
          },
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            padding: contentPadding,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Score
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Game Board
                    Container(
                      width: boardSize,
                      height: boardSize,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                            ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, index) {
                          final int x = index % gridSize;
                          final int y = index ~/ gridSize;
                          final Point<int> point = Point(x, y);

                          Color cellColor = Colors.transparent;
                          if (snake.first == point) {
                            cellColor = Colors.green.shade700;
                          } else if (snake.contains(point)) {
                            cellColor = Colors.green;
                          } else if (food == point) {
                            cellColor = Colors.red;
                          }

                          return Container(
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: cellColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Controls
                    if (!isPlaying)
                      FilledButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(score > 0 ? 'Play Again' : 'Start Game'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _changeDirection(Direction.up),
                                icon: const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _changeDirection(Direction.left),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                              ),
                              const SizedBox(width: 60),
                              IconButton(
                                onPressed: () =>
                                    _changeDirection(Direction.right),
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _changeDirection(Direction.down),
                                icon: const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                                iconSize: 32,
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    const Text(
                      'Use arrow keys or buttons to move',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}
