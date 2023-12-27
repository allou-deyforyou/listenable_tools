import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
sealed class AsyncState extends Equatable {
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
class SuccessState<E extends AsyncEvent, T> extends AsyncState {
  const SuccessState(this.data, {required this.event});

  final T data;
  final E event;

  @override
  List<Object?> get props => [data];
}

// State representing a failed asynchronous operation
class FailureState<E extends AsyncEvent, T> extends AsyncState {
  const FailureState(this.data, {required this.event});

  final T data;
  final E event;

  @override
  List<Object?> get props => [data];
}

// Controller class to manage asynchronous states and events
class AsyncController<T> extends ValueNotifier<T> {
  AsyncController(this.initState, {this.debug = !kReleaseMode})
      : super(initState) {
    if (debug) log('$runtimeType created');
  }

  final T initState;
  final bool debug;

  // Custom notifier function to update state and log events
  AsyncEmitter<T> _notifier(AsyncEvent<T> event) {
    return (T value) {
      super.value = value;
      if (debug) log('${event.runtimeType}($value)', name: '$runtimeType');
    };
  }

  // Reset the state to the initial state
  void reset() {
    super.value = initState;
    if (debug) log('$runtimeType reseted');
  }

  // Run an asynchronous event and update the state accordingly
  Future<void> run(AsyncEvent<T> event) => event.handle(_notifier(event));
}
