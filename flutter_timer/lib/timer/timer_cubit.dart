import 'dart:async';

import 'package:flutter_timer/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>? _tickerSubscription;

  TimerCubit({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration));

  void start() {
    emit(TimerRunInProgress(state.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: state.duration).listen(
      (duration) {
        emit(duration > 0 ? TimerRunInProgress(duration) : TimerRunComplete());
      },
    );
  }

  void pause() {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void resume() {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void reset() {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_duration));
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
