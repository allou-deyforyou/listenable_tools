import 'dart:developer';

import 'package:flutter/foundation.dart';

abstract class AsyncState {
  const AsyncState();
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
  final T? event;
}

abstract class AsyncEvent<T> {
  const AsyncEvent();

  @protected
  Stream<T> handle();
}

class AsyncController<T> extends ValueNotifier<T> {
  AsyncController(super.value, {this.debug = kDebugMode});
  final bool debug;

  ValueChanged<T> _notifier(AsyncEvent<T> event) {
    return (T value) {
      super.value = value;
      if (debug) log('${event.runtimeType}($value)');
    };
  }

  Future<void> run(AsyncEvent<T> event) => event.handle().forEach(_notifier(event));
}
