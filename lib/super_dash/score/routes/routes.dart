import 'package:flutter/material.dart';
import '../../score/game_over/game_over.dart';
import '../../score/score.dart';

List<Page<void>> onGenerateScorePages(
  ScoreState state,
  List<Page<void>> pages,
) {
  return switch (state.status) {
    ScoreStatus.gameOver => [GameOverPage.page()],
    ScoreStatus.inputInitials => [InputInitialsPage.page()],
    ScoreStatus.scoreOverview => [ScoreOverviewPage.page()],
  };
}
