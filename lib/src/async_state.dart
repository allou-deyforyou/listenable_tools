import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class AsyncState {
  const AsyncState();
}

class InitialState extends AsyncState {
  const InitialState();
}

class PendingState extends AsyncState {
  const PendingState();
}

class SuccessState<T> extends AsyncState {
  const SuccessState(this.data);
  final T data;
}

class FailureState<T extends AsyncEvent> extends AsyncState {
  const FailureState({
    required this.code,
    this.event,
  });
  final String code;
  final AsyncEvent? event;
}

abstract class AsyncEvent<T extends AsyncNotifier> {
  const AsyncEvent();
  Future<void> handle(T notifier);
}

class AsyncNotifier<T extends AsyncState> extends ValueNotifier<T> {
  AsyncNotifier({
    required this.initialState,
    this.debug = kDebugMode,
  }) : super(initialState);
  final T initialState;
  final bool debug;

  @override
  set value(T newValue) {
    super.value = newValue;
    if (debug) debugPrint('$runtimeType($newValue)');
  }

  Future<T> add(AsyncEvent event) {
    return event.handle(this).then((_) => value);
  }

  void reset() => value = initialState;
}
