library listenable_tools.async;

import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef AsyncEmitter<T> = void Function(T value);

abstract class AsyncState {
  const AsyncState();

  Record get equality => ();

  @override
  bool operator ==(covariant AsyncState other) {
    if (identical(this, other)) return true;
    return other.equality == equality;
  }

  @override
  int get hashCode => equality.hashCode;

  @override
  String toString() {
    return '$runtimeType($equality)';
  }
}

class InitState extends AsyncState {
  const InitState();
}

class PendingState extends AsyncState {
  const PendingState();
}

class SuccessState<T> extends AsyncState {
  const SuccessState(this.data);
  final T data;

  @override
  Record get equality => (data,);
}

class FailureState<T extends AsyncEvent> extends AsyncState {
  const FailureState({
    required this.code,
    this.event,
  });
  final String code;
  final T? event;
  @override
  Record get equality => (code, event);
}

abstract class AsyncEvent<T> {
  const AsyncEvent();
  @protected
  Future<void> handle(ValueChanged<T> emit);
}

class AsyncController<T> extends ValueNotifier<T> {
  AsyncController(this.initState, {this.debug = kDebugMode}) : super(initState);
  final T initState;
  final bool debug;

  AsyncEmitter<T> _notifier(AsyncEvent<T> event) {
    return (T value) {
      super.value = value;
      if (debug) debugPrint('${event.runtimeType}($value)');
    };
  }

  void reset() => value = initState;
  Future<void> run(AsyncEvent<T> event) => event.handle(_notifier(event));
}

class Singleton {
  const Singleton._(this._entries);
  final HashMap<String, dynamic> _entries;

  static Singleton? _singleton;
  static T instance<T extends AsyncController>(T Function() createFunction, [String name = '']) {
    _singleton ??= Singleton._(HashMap<String, T>());
    return _singleton!._entries.putIfAbsent(T.runtimeType.toString() + name, createFunction);
  }
}
