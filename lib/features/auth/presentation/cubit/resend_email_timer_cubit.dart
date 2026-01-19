import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResendEmailCubit extends Cubit<int> {
  Timer? _timer;

  ResendEmailCubit() : super(0);

  void startCountdown([int seconds = 60]) {
    emit(seconds);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == 0) {
        timer.cancel();
      } else {
        emit(state - 1);
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
