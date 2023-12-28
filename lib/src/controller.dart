import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

// Custom callback for asynchronous event emission
typedef AsyncEmitter<T> = void Function(T value);

// Base abstract class for asynchronous events
abstract class AsyncEvent<T> {
  const AsyncEvent();

  @override
  String toString() => '$runtimeType';

  @protected
  Future<void> handle(AsyncEmitter<T> emit);
}

// Base abstract class for asynchronous states
abstract class AsyncState extends Equatable {
  const AsyncState();

  @override
  List<Object?> get props => const [];
}

// Initial state representing the uninitialized state
class InitState extends AsyncState {
  const InitState();
}

// State representing that an asynchronous operation is pending
class PendingState extends AsyncState {
  const PendingState();
}

// State representing a successful asynchronous operation with data
class SuccessState<T> extends AsyncState {
  const SuccessState(this.data, {this.event});

  final T data;
  final AsyncEvent? event;

  @override
  List<Object?> get props => [data];
}

// State representing a failed asynchronous operation
class FailureState<T> extends AsyncState {
  const FailureState(this.data, {this.event});

  final T data;
  final AsyncEvent? event;

  @override
  List<Object?> get props => [data];
}

// Controller class to manage asynchronous states and events
class AsyncController<T> extends ValueNotifier<T> {
  AsyncController(this.initState, {bool? debug})
      : _debug = debug ?? !kReleaseMode,
        super(initState) {
    if (_debug) log('$runtimeType created');
  }

  final T initState;
  final bool _debug;

  // Custom notifier function to update state and log events
  AsyncEmitter<T> _notifier(AsyncEvent<T> event) {
    return (T value) {
      Timer.run(() {
        if (_debug) log('${event.runtimeType}(${super.value} -> $value)', name: '$runtimeType');
        super.value = value;
      });
    };
  }

  // Reset the state to the initial state
  void reset() {
    super.value = initState;
    if (_debug) log('$runtimeType reset');
  }

  // Run an asynchronous event and update the state accordingly
  Future<void> run(AsyncEvent<T> event) => event.handle(_notifier(event));
}
