import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:audioplayers/audioplayers.dart';

// void main() {
//   runApp(const ChessApp());
// }

// ---------------------------------------------------------------------------
// 1. CONFIGURATION & MODELS
// ---------------------------------------------------------------------------

enum GameMode { pvp, vsComputer }

enum Difficulty { easy, medium, hard }

class GameSettings {
  final GameMode mode;
  final Difficulty difficulty;

  GameSettings({required this.mode, required this.difficulty});
}

// ---------------------------------------------------------------------------
// 2. THE APP ROOT
// ---------------------------------------------------------------------------

// class ChessApp extends StatelessWidget {
//   const ChessApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Pro Chess',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.blueGrey,
//         scaffoldBackgroundColor: const Color(0xFF1E1E1E),
//         useMaterial3: true,
//       ),
//       home: const MainMenuScreen(),
//     );
//   }
// }

// ---------------------------------------------------------------------------
// 3. MAIN MENU
// ---------------------------------------------------------------------------

class ChessMainmenuScreen extends StatelessWidget {
  const ChessMainmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF000000)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.videogame_asset,
                size: 100,
                color: Colors.white70,
              ),
              const SizedBox(height: 20),
              const Text(
                "FLUTTER CHESS",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 60),
              _buildMenuButton(context, "Player vs Player", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameScreen(settings: null),
                  ),
                );
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, "Vs Computer (Easy)", () {
                _startGame(context, Difficulty.easy);
              }),
              const SizedBox(height: 15),
              _buildMenuButton(context, "Vs Computer (Medium)", () {
                _startGame(context, Difficulty.medium);
              }),
              const SizedBox(height: 15),
              _buildMenuButton(context, "Vs Computer (Hard)", () {
                _startGame(context, Difficulty.hard);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, Difficulty diff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          settings: GameSettings(mode: GameMode.vsComputer, difficulty: diff),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 280,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[700],
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. GAME SCREEN (RESPONSIVE & AUDIO)
// ---------------------------------------------------------------------------

class GameScreen extends StatefulWidget {
  final GameSettings? settings;

  const GameScreen({super.key, this.settings});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late chess_lib.Chess _chess;
  late AudioPlayer _audioPlayer;

  String? _selectedSquare;
  List<String> _validMoves = [];
  bool _isAiThinking = false;
  String _lastMove = "";

  // Board colors
  final Color _lightSquare = const Color(0xFFF0D9B5);
  final Color _darkSquare = const Color(0xFFB58863);

  @override
  void initState() {
    super.initState();
    _chess = chess_lib.Chess();
    _audioPlayer = AudioPlayer();

    // Preload sounds for lower latency
    _audioPlayer.setSource(AssetSource('sounds/move_self.mp3'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Plays sound based on game event
  Future<void> _playSound(bool isCapture, bool isCheck, bool isGameOver) async {
    try {
      if (isGameOver) {
        await _audioPlayer.play(AssetSource('sounds/game_over.mp3'));
      } else if (isCheck) {
        await _audioPlayer.play(AssetSource('sounds/notify.mp3'));
      } else if (isCapture) {
        await _audioPlayer.play(AssetSource('sounds/capture.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/move_self.mp3'));
      }
    } catch (e) {
      // Fail silently if assets are missing
      debugPrint("Audio Error (Assets likely missing): $e");
    }
  }

  void _onSquareTap(String squareKey) {
    if (_isAiThinking) return;
    if (_chess.game_over) return;

    if (_validMoves.contains(squareKey)) {
      _makeMove(_selectedSquare!, squareKey);
      return;
    }

    final piece = _chess.get(squareKey);
    if (piece != null && piece.color == _chess.turn) {
      setState(() {
        _selectedSquare = squareKey;
        final moves = _chess.moves({'square': squareKey, 'verbose': true});
        _validMoves = moves.map((m) => m['to'] as String).toList();
      });
    } else {
      setState(() {
        _selectedSquare = null;
        _validMoves = [];
      });
    }
  }

  void _makeMove(String from, String to) async {
    // Attempt move
    final success = _chess.move({'from': from, 'to': to});

    if (success) {
      // FIX: Access .move.captured instead of .captured directly on the State object
      final lastMoveState = _chess.history.last;
      final lastMove = lastMoveState.move;

      bool isCapture = lastMove.captured != null;
      bool isCheck = _chess.in_check;
      bool isGameOver = _chess.game_over;

      _playSound(isCapture, isCheck, isGameOver);

      setState(() {
        _lastMove = "$from-$to";
        _selectedSquare = null;
        _validMoves = [];
      });

      if (_chess.game_over) {
        _showGameOverDialog();
        return;
      }

      // AI Turn
      if (widget.settings?.mode == GameMode.vsComputer &&
          _chess.turn == chess_lib.Color.BLACK) {
        setState(() => _isAiThinking = true);
        await Future.delayed(
          const Duration(milliseconds: 500),
        ); // Natural pause
        await _makeAiMove();
        setState(() => _isAiThinking = false);
      }
    }
  }

  Future<void> _makeAiMove() async {
    int depth = 1;
    switch (widget.settings!.difficulty) {
      case Difficulty.easy:
        depth = 1;
        break;
      case Difficulty.medium:
        depth = 2;
        break;
      case Difficulty.hard:
        depth = 3;
        break;
    }

    String? bestMove = ChessAI.getBestMove(_chess, depth);
    if (bestMove != null) {
      String from = bestMove.substring(0, 2);
      String to = bestMove.substring(2, 4);

      final success = _chess.move({'from': from, 'to': to});

      // Play sound for AI move
      if (success) {
        // FIX: Access .move.captured here as well
        final lastMoveState = _chess.history.last;
        final lastMove = lastMoveState.move;

        _playSound(
          lastMove.captured != null,
          _chess.in_check,
          _chess.game_over,
        );
      }

      if (_chess.game_over) _showGameOverDialog();
    }
  }

  void _resetGame() {
    setState(() {
      _chess.reset();
      _selectedSquare = null;
      _validMoves = [];
      _isAiThinking = false;
      _lastMove = "";
    });
  }

  void _showGameOverDialog() {
    String result = "";
    if (_chess.in_checkmate) {
      result =
          "Checkmate! ${_chess.turn == chess_lib.Color.WHITE ? 'Black' : 'White'} Wins";
    } else if (_chess.in_draw) {
      result = "Draw!";
    } else if (_chess.in_stalemate) {
      result = "Stalemate!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text("Rematch"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Menu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.settings == null
              ? "PvP"
              : "Vs CPU (${widget.settings!.difficulty.name})",
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetGame),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Logic:
          // If width is large (Tablet/Web), use Row.
          // If width is small (Mobile), use Column.
          bool isLandscape =
              constraints.maxWidth > constraints.maxHeight ||
              constraints.maxWidth > 600;

          if (isLandscape) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildBoardWidget(),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 1, child: _buildGameInfoPanel()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildGameInfoPanel(isCompact: true),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildBoardWidget(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildGameInfoPanel({bool isCompact = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isCompact ? Colors.transparent : Colors.black12,
      child: Column(
        mainAxisAlignment: isCompact
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          _buildPlayerIndicator(
            "Black (CPU)",
            _chess.turn == chess_lib.Color.BLACK,
          ),
          const SizedBox(height: 20),
          if (_isAiThinking)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text(
                  "Thinking...",
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ],
            ),
          const SizedBox(height: 20),
          _buildPlayerIndicator(
            "White (You)",
            _chess.turn == chess_lib.Color.WHITE,
          ),

          if (!isCompact) ...[
            const SizedBox(height: 40),
            const Divider(),
            Text(
              "Last Move: $_lastMove",
              style: const TextStyle(fontSize: 16, color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerIndicator(String label, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[700] : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: Colors.greenAccent, width: 2)
            : null,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.white54,
        ),
      ),
    );
  }

  Widget _buildBoardWidget() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown[900]!, width: 8),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          final int rank = 7 - (index ~/ 8);
          final int file = index % 8;
          final String squareName =
              "${String.fromCharCode(97 + file)}${rank + 1}";

          final bool isLight = (rank + file) % 2 != 0;
          final Color squareColor = isLight ? _lightSquare : _darkSquare;

          Color? overlayColor;
          if (_selectedSquare == squareName) {
            overlayColor = Colors.green.withValues(alpha: 0.6);
          } else if (_validMoves.contains(squareName)) {
            overlayColor = Colors.blue.withValues(
              alpha: 0.5,
            ); // Valid move target
          } else if (_lastMove.contains(squareName)) {
            overlayColor = Colors.yellow.withValues(
              alpha: 0.3,
            ); // Highlight last move
          }

          final piece = _chess.get(squareName);

          return GestureDetector(
            onTap: () => _onSquareTap(squareName),
            child: Container(
              color: squareColor,
              child: Stack(
                children: [
                  if (overlayColor != null) Container(color: overlayColor),

                  // Coordinate Labels (only on edges)
                  if (file == 0)
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Text(
                        "${rank + 1}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLight ? _darkSquare : _lightSquare,
                        ),
                      ),
                    ),
                  if (rank == 0)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Text(
                        String.fromCharCode(97 + file),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLight ? _darkSquare : _lightSquare,
                        ),
                      ),
                    ),

                  // Move Hint Dot
                  if (_validMoves.contains(squareName) && piece == null)
                    Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  // The Piece
                  if (piece != null) Center(child: _buildPieceIcon(piece)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieceIcon(chess_lib.Piece piece) {
    IconData icon;
    switch (piece.type) {
      case chess_lib.PieceType.PAWN:
        icon = Icons.shield_outlined;
        break; // Pawn
      case chess_lib.PieceType.ROOK:
        icon = Icons.fort;
        break; // Rook
      case chess_lib.PieceType.KNIGHT:
        icon = Icons.bedroom_baby;
        break; // Knight (Closest visual match)
      case chess_lib.PieceType.BISHOP:
        icon = Icons.change_history;
        break; // Bishop
      case chess_lib.PieceType.QUEEN:
        icon = Icons.diamond;
        break; // Queen
      case chess_lib.PieceType.KING:
        icon = Icons.emoji_events;
        break; // King
      default:
        icon = Icons.help;
    }

    return Hero(
      tag: "${piece.type}-${piece.color}", // Simplistic Hero tag
      child: Icon(
        icon,
        color: piece.color == chess_lib.Color.WHITE
            ? Colors.white
            : Colors.black,
        size: 28, // Scaled down slightly to fit better
        shadows: [
          Shadow(
            color: piece.color == chess_lib.Color.WHITE
                ? Colors.black54
                : Colors.white54,
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. ARTIFICIAL INTELLIGENCE (ENGINE)
// ---------------------------------------------------------------------------

class ChessAI {
  static Map<chess_lib.PieceType, int> pieceValues = {
    chess_lib.PieceType.PAWN: 10,
    chess_lib.PieceType.KNIGHT: 30,
    chess_lib.PieceType.BISHOP: 30,
    chess_lib.PieceType.ROOK: 50,
    chess_lib.PieceType.QUEEN: 90,
    chess_lib.PieceType.KING: 900,
  };

  static String? getBestMove(chess_lib.Chess game, int depth) {
    String currentFen = game.fen;
    double bestValue = -double.infinity;
    String? bestMove;

    var moves = game.moves({'verbose': true});
    moves.shuffle();

    for (var move in moves) {
      chess_lib.Chess tempGame = chess_lib.Chess.fromFEN(currentFen);
      tempGame.move(move);

      double boardValue = _minimax(
        tempGame,
        depth - 1,
        -double.infinity,
        double.infinity,
        false,
      );

      if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = "${move['from']}${move['to']}";
      }
    }

    return bestMove;
  }

  static double _minimax(
    chess_lib.Chess game,
    int depth,
    double alpha,
    double beta,
    bool isMaximizing,
  ) {
    if (depth == 0 || game.game_over) {
      return _evaluateBoard(game);
    }

    var moves = game.moves({'verbose': true});

    if (isMaximizing) {
      double maxEval = -double.infinity;
      for (var move in moves) {
        chess_lib.Chess tempGame = chess_lib.Chess.fromFEN(game.fen);
        tempGame.move(move);
        double eval = _minimax(tempGame, depth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (var move in moves) {
        chess_lib.Chess tempGame = chess_lib.Chess.fromFEN(game.fen);
        tempGame.move(move);
        double eval = _minimax(tempGame, depth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static double _evaluateBoard(chess_lib.Chess game) {
    double totalEvaluation = 0;

    for (var piece in game.board) {
      if (piece != null) {
        int value = pieceValues[piece.type] ?? 0;
        if (piece.color == chess_lib.Color.BLACK) {
          totalEvaluation += value;
        } else {
          totalEvaluation -= value;
        }
      }
    }
    return totalEvaluation;
  }
}
