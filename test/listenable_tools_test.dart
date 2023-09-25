import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_tools/async.dart';

AsyncController<int> get controller => Singleton.instance(() => AsyncController<int>(0));

void main() {
  test('Increment', () async {
    await controller.run(const Increment());
    expect(controller.value, 1);
    await controller.run(const Increment());
    expect(controller.value, 2);
  });

  test('Decrement', () async {
    await controller.run(const Decrement());
    expect(controller.value, 1);
    await controller.run(const Decrement());
    expect(controller.value, 0);
  });
}

class Increment extends AsyncEvent<int> {
  const Increment();
  @override
  Stream<int> handle(int currentState) async* {
    yield currentState + 1;
  }
}

class Decrement extends AsyncEvent<int> {
  const Decrement();
  @override
  Stream<int> handle(int currentState) async* {
    yield currentState - 1;
  }
}
