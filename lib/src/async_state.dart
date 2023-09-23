import 'dart:async';

import 'package:flutter/foundation.dart';

sealed class AsyncState {
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

class AsyncNotifier extends ValueNotifier<AsyncState> {
  AsyncNotifier([
    super.value = const Initial(),
    this.debug = kDebugMode,
  ]);
  final bool debug;

  @override
  set value(AsyncState newValue) {
    super.value = newValue;
    if (debug) debugPrint('$runtimeType($newValue)');
  }

  Future<AsyncState> add(AsyncEvent event) {
    return event.handle(this).then((_) => value);
  }
}
