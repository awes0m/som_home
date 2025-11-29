import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'score_event.dart';
part 'score_state.dart';

class ScoreBloc extends Bloc<ScoreEvent, ScoreState> {
  ScoreBloc({
    required this.score,
  }) : super(const ScoreState()) {
    on<ScoreSubmitted>(_onScoreSubmitted);
    on<ScoreInitialsUpdated>(_onScoreInitialsUpdated);
    on<ScoreInitialsSubmitted>(_onScoreInitialsSubmitted);
  }

  final int score;

  final initialsRegex = RegExp('[A-Z]{3}');

  void _onScoreSubmitted(
    ScoreSubmitted event,
    Emitter<ScoreState> emit,
  ) {
    emit(
      state.copyWith(
        status: ScoreStatus.inputInitials,
      ),
    );
  }

  void _onScoreInitialsUpdated(
    ScoreInitialsUpdated event,
    Emitter<ScoreState> emit,
  ) {
    final initials = [...state.initials];
    initials[event.index] = event.character;
    final initialsStatus =
        (state.initialsStatus == InitialsFormStatus.blacklisted)
            ? InitialsFormStatus.initial
            : state.initialsStatus;
    emit(state.copyWith(initials: initials, initialsStatus: initialsStatus));
  }

  Future<void> _onScoreInitialsSubmitted(
    ScoreInitialsSubmitted event,
    Emitter<ScoreState> emit,
  ) async {
    if (!_hasValidPattern()) {
      emit(state.copyWith(initialsStatus: InitialsFormStatus.invalid));
    } else if (_isInitialsBlacklisted()) {
      emit(state.copyWith(initialsStatus: InitialsFormStatus.blacklisted));
    } else {
      emit(state.copyWith(initialsStatus: InitialsFormStatus.loading));
      await Future.delayed(const Duration(milliseconds: 500));
      emit(
        state.copyWith(
          status: ScoreStatus.scoreOverview,
          initialsStatus: InitialsFormStatus.success,
        ),
      );
    }
  }

  bool _hasValidPattern() {
    final value = state.initials;
    return value.isNotEmpty && initialsRegex.hasMatch(value.join());
  }

  bool _isInitialsBlacklisted() {
    return _blacklist.contains(state.initials.join());
  }
}

const _blacklist = [
  'FUK',
  'FUC',
  'COK',
  'DIK',
  'KKK',
  'SHT',
  'CNT',
  'ASS',
  'CUM',
  'FAG',
  'GAY',
  'GOD',
  'JEW',
  'SEX',
  'TIT',
  'WTF',
];
