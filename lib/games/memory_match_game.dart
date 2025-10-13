import 'dart:math';
import 'package:flutter/material.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<_CardModel> cards;
  _CardModel? first;
  _CardModel? second;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.ac_unit,
      Icons.pets,
      Icons.coffee,
      Icons.flash_on,
      Icons.beach_access,
      Icons.spa,
    ];
    cards = [
      for (final i in icons) _CardModel(icon: i),
      for (final i in icons) _CardModel(icon: i),
    ];
    cards.shuffle(Random());
    first = null;
    second = null;
    moves = 0;
    setState(() {});
  }

  void _tapCard(_CardModel c) async {
    if (c.matched || c.flipped) return;
    if (first != null && second != null) return;

    setState(() => c.flipped = true);

    if (first == null) {
      first = c;
      return;
    }
    second = c;
    moves++;

    if (first!.icon == second!.icon) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        first!.matched = true;
        second!.matched = true;
        first = null;
        second = null;
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        first!.flipped = false;
        second!.flipped = false;
        first = null;
        second = null;
      });
    }
  }

  bool get complete => cards.every((c) => c.matched);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSize = constraints.biggest.shortestSide.clamp(
          240.0,
          420.0,
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
                    complete ? 'Completed in $moves moves!' : 'Moves: $moves',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: cards.length,
                      itemBuilder: (context, i) {
                        final _CardModel c = cards[i];
                        return GestureDetector(
                          onTap: () => _tapCard(c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: c.matched
                                  ? Colors.green.shade400
                                  : c.flipped
                                  ? Colors.blueGrey.shade700
                                  : Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Center(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: c.flipped || c.matched ? 1 : 0,
                                child: Icon(
                                  c.icon,
                                  color: Colors.white,
                                  size: boardSize / 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _newGame,
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
}

class _CardModel {
  final IconData icon;
  bool flipped = false;
  bool matched = false;
  _CardModel({required this.icon});
}
