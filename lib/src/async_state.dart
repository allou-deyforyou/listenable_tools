import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class AsyncState {
  const AsyncState();
}

class Initial extends AsyncState {
  const Initial();
}

class Pending extends AsyncState {
  const Pending();
}

class Success<T> extends AsyncState {
  const Success(this.data);
  final T data;
}

class Failure<T extends AsyncEvent> extends AsyncState {
  const Failure({
    required this.code,
    this.event,
  });
  final String code;
  final AsyncEvent? event;
}

sealed class AsyncEvent {
  const AsyncEvent();
  Future<void> handle(AsyncNotifier notifier);
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
