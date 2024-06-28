import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

/// Controller class to manage asynchronous states and events
class AsyncController<T> extends ValueNotifier<T?> {
  AsyncController([this.initState])
      : _isDisposed = ValueNotifier(false),
        super(initState) {
    log('$runtimeType created');
  }

  final T? initState;
  final ValueNotifier<bool> _isDisposed;

  /// Custom notifier function to update state and log events
  AsyncEmitter<T> _notifier(AsyncEvent<T> event) {
    return AsyncEmitter<T>(this, event);
  }

  /// Reset the state to the initial state
  void reset() {
    log('$runtimeType reset');
    value = initState;
  }

  /// Run an asynchronous event and update the state accordingly
  Future<void> add(AsyncEvent<T> event) {
    log('${event.runtimeType} executed');
    return event.handle(_notifier(event));
  }

  @override
  void dispose() {
    log('$runtimeType closed');
    _isDisposed.value = true;
    super.dispose();
  }
}

/// Custom callback for asynchronous event emission
class AsyncEmitter<T> {
  const AsyncEmitter(this._controller, this._event);

  final AsyncController<T> _controller;
  final AsyncEvent<T> _event;

  /// Listen to a stream and handle data or errors
  Future<void> listen<V>(
    Stream<V> stream, {
    required void Function(V data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    final completer = Completer<void>();
    final subscription = stream.listen(
      onData,
      onError: (error, stackTrace) {
        onError?.call(error, stackTrace);
        completer.completeError(error, stackTrace);
      },
      onDone: completer.complete,
      cancelOnError: onError != null,
    );

    _controller._isDisposed.addListener(subscription.cancel);
    await completer.future.whenComplete(
      () => _controller._isDisposed.removeListener(subscription.cancel),
    );
  }

  /// Emit a new value to the controller
  void call(T value) {
    if (!_controller._isDisposed.value) {
      log('${_event.runtimeType}(${_controller.value} -> $value)', name: '$runtimeType');
      _controller.value = value;
    }
  }
}

/// Base abstract class for asynchronous events
abstract class AsyncEvent<T> {
  const AsyncEvent();

  @override
  String toString() => '$runtimeType';

  @protected
  Future<void> handle(AsyncEmitter<T> emit);
}

/// Base abstract class for asynchronous states
abstract class AsyncState extends Equatable {
  const AsyncState();

  @override
  List<Object?> get props => [];
}

/// State representing that an asynchronous operation is pending
class PendingState<E extends AsyncEvent> extends AsyncState {
  const PendingState({required this.event});

  final E? event;
}

/// State representing a successful asynchronous operation with data
class SuccessState<E extends AsyncEvent, T> extends AsyncState {
  const SuccessState(this.data, {required this.event});

  final T data;
  final E? event;

  @override
  List<Object?> get props => [data, event];
}

/// State representing a failed asynchronous operation
class FailureState<E extends AsyncEvent, T> extends AsyncState {
  const FailureState(this.error, {required this.event});

  final Object error;
  final E? event;

  @override
  List<Object?> get props => [error, event];
}
