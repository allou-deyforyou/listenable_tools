import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_tools/listenable_tools.dart';

AsyncController<int> get controller =>
    Singleton.instance(() => AsyncController<int>(0));

void main() {
  final controller = AsyncController<AsyncState>();
  test('Increment', () async {
    controller.run(const Increment());

    debugPrint(controller.value.toString());
  });

  test('Decrement', () async {
    controller.run(const Decrement());

    debugPrint(controller.value.toString());
  });
}

sealed class AutoIncrement extends AsyncEvent<AsyncState> {
  const AutoIncrement();
}

class Increment extends AutoIncrement {
  const Increment();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    emit(SuccessState(1, event: this));
  }
}

class Decrement extends AutoIncrement {
  const Decrement();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    emit(SuccessState(2, event: this));
  }
}
