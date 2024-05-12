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

// State representing that an asynchronous operation is pending
class PendingState<E extends AsyncEvent> extends AsyncState {
  const PendingState({required this.event});
  final E? event;
}

// State representing a successful asynchronous operation with data
class SuccessState<E extends AsyncEvent, T> extends AsyncState {
  const SuccessState(this.data, {required this.event});
  final T data;
  final E? event;
  @override
  List<Object?> get props => [data];
}

// State representing a failed asynchronous operation
class FailureState<E extends AsyncEvent, T> extends AsyncState {
  const FailureState(this.data, {required this.event});
  final T data;
  final E? event;
  @override
  List<Object?> get props => [data];
}

// Controller class to manage asynchronous states and events
class AsyncController<T> extends ValueNotifier<T?> {
  AsyncController([this.initState]) : super(initState) {
    log('$runtimeType created');
  }

  final T? initState;
  bool? _isDisposed;

  // Custom notifier function to update state and log events
  AsyncEmitter<T> _notifier(AsyncEvent<T> event) {
    return (T value) {
      Timer.run(() {
        if (_isDisposed == null) {
          log('${event.runtimeType}(${super.value} -> $value)', name: '$runtimeType');

          super.value = value;
        }
      });
    };
  }

  // Reset the state to the initial state
  void reset() {
    log('$runtimeType reset');

    super.value = initState;
  }

  // Run an asynchronous event and update the state accordingly
  Future<void> add(AsyncEvent<T> event) {
    log('${event.runtimeType} executed');

    return event.handle(_notifier(event));
  }

  @override
  void dispose() {
    log('$runtimeType closed');

    super.dispose();

    _isDisposed = true;
  }
}
