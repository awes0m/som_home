import 'dart:math';
import 'package:flutter/material.dart';

class RockPaperScissorsGame extends StatefulWidget {
  const RockPaperScissorsGame({super.key});

  @override
  State<RockPaperScissorsGame> createState() => _RockPaperScissorsGameState();
}

class _RockPaperScissorsGameState extends State<RockPaperScissorsGame> {
  String? _playerChoice;
  String? _computerChoice;
  String _result = 'Choose your weapon!';
  int _playerScore = 0;
  int _computerScore = 0;

  final List<String> _choices = ['rock', 'paper', 'scissors'];
  final Map<String, IconData> _choiceIcons = {
    'rock': Icons.sports_baseball,
    'paper': Icons.description,
    'scissors': Icons.content_cut,
  };

  void _playGame(String playerChoice) {
    final random = Random();
    final String computerChoice = _choices[random.nextInt(_choices.length)];

    setState(() {
      _playerChoice = playerChoice;
      _computerChoice = computerChoice;
      _result = _determineWinner(playerChoice, computerChoice);
    });
  }

  String _determineWinner(String player, String computer) {
    if (player == computer) {
      return 'It\'s a Draw!';
    } else if ((player == 'rock' && computer == 'scissors') ||
        (player == 'paper' && computer == 'rock') ||
        (player == 'scissors' && computer == 'paper')) {
      _playerScore++;
      return 'You Win!';
    } else {
      _computerScore++;
      return 'Computer Wins!';
    }
  }

  void _resetGame() {
    setState(() {
      _playerChoice = null;
      _computerChoice = null;
      _result = 'Choose your weapon!';
      _playerScore = 0;
      _computerScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 600;
        final double iconButtonSize = isCompact ? 32 : 40;
        final double displayBox = isCompact ? 80 : 110;
        final EdgeInsets contentPadding = isCompact
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 32, vertical: 24);

        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          padding: contentPadding,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flex(
                    direction: isCompact ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildChoiceDisplay('You', _playerChoice, displayBox),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 0 : 24,
                          vertical: isCompact ? 12 : 0,
                        ),
                        child: Text(
                          'VS',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      _buildChoiceDisplay(
                        'Computer',
                        _computerChoice,
                        displayBox,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _choices.map((choice) {
                      return SizedBox(
                        width: displayBox,
                        height: displayBox,
                        child: ElevatedButton(
                          onPressed: () => _playGame(choice),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(iconButtonSize / 2),
                            shape: const CircleBorder(),
                          ),
                          child: Icon(
                            _choiceIcons[choice],
                            size: iconButtonSize,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text('Reset Game'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoiceDisplay(String label, String? choice, double side) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Center(
            child: choice != null
                ? Icon(
                    _choiceIcons[choice],
                    size: side / 1.8,
                    color: Colors.white,
                  )
                : Text(
                    '?',
                    style: TextStyle(
                      fontSize: side / 1.6,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
