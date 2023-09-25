import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_tools/async.dart';

AsyncController<int> get controller => Singleton.instance(() => AsyncController<int>(0));

void main() {
  test('Increment', () async {
    debugPrint((AutoIncrement == AutoIncrement).toString());
  });

  test('Decrement', () async {});
}

sealed class AutoIncrement extends AsyncEvent<int> {
  const AutoIncrement();
}

class Increment extends AutoIncrement {
  const Increment();
  @override
  Future<void> handle(AsyncEmitter<int> emit) async {
    emit(0 + 1);
  }
}

class Decrement extends AutoIncrement {
  const Decrement();
  @override
  Future<void> handle(AsyncEmitter<int> emit) async {
    emit(0 + 1);
  }
}
