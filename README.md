## Listenable Tools

Welcome to **listenable_tools**, a Dart package designed to simplify state management in your Flutter applications. With `listenable_tools`, you can easily manage singleton instances, ensuring your application has a single source of truth for critical components. This package offers robust and flexible tools for working with `Listenable` objects, providing a streamlined way to build reactive and efficient applications.

### Features

- **AsyncController Management**: Manage asynchronous states and events in your application.
- **Singleton Management**: Create and manage singleton instances effortlessly.
- **Notifier Widgets**: Widgets that automatically rebuild or trigger callbacks when a `Listenable` changes.
- **Multi-Notifier Handling**: Combine multiple `Listenable` objects into a single reactive unit.

### Installation

Add `listenable_tools` to your `pubspec.yaml`:

```yaml
dependencies:
  listenable_tools: ^2.1.0
```

Then, run:

```sh
flutter pub get
```

### Usage

#### AsyncController Management

Manage state of counter. Increment or Decrement counter.

```dart
import 'package:flutter/material.dart';
import 'package:listenable_tools/listenable_tools.dart';

class Increment extends AsyncEvent<AsyncState>  {
  const Increment();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    emit(SuccessState(1, event: this));
  }
}

class Decrement extends AsyncEvent<AsyncState> {
  const Decrement();
  @override
  Future<void> handle(AsyncEmitter<AsyncState> emit) async {
    emit(SuccessState(2, event: this));
  }
}

class MyAsyncWidget extends StatefulWidget {
  const MyAsyncWidget({super.key});

  @override
  State<MyAsyncWidget> createState() => _MyAsyncWidgetState();
}

class _MyAsyncWidgetState extends State<MyAsyncWidget> {
  final _controller = AsyncController<AsyncState>(null);

  void _incrementCounter() async {
    _controller.add(const Increment());
  }

  void _decrementCounter() async {
    _controller.add(const Decrement());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Counter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ControllerBuilder(
              controller: _controller,
              builder: (context, state, child) {
                if (state case SuccessState<Decrement, int>(:final data)) {
                  return Text(
                    '$data',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(CupertinoIcons.add),
          ),
          const SizedBox(height: 12.0),
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrement',
            child: const Icon(CupertinoIcons.minus),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
```

#### Singleton Management

Ensure only one instance of a type exists in your application:

```dart
import 'package:listenable_tools/listenable_tools.dart';

// Create or retrieve a singleton instance
MyService myService = singleton(() => MyService(), 'myServiceName');
```

#### Notifier Widgets

Easily create widgets that react to changes in `Listenable` objects:

```dart
import 'package:flutter/material.dart';
import 'package:listenable_tools/listenable_tools.dart';

class MyWidget extends StatelessWidget {
  final AsyncController<int> counter = AsyncController<int>(0);

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      listenable: counter,
      builder: (context, child) {
        return Text('Counter: ${counter.value}');
      },
    );
  }
}
```

#### Multi-Notifier Handling

Combine multiple `Listenable` objects and react to their changes collectively:

```dart
import 'package:flutter/material.dart';
import 'package:listenable_tools/listenable_tools.dart';

class MyMultiNotifierWidget extends StatelessWidget {
  final AsyncController<int> counter1 = AsyncController<int>(0);
  final ValueNotifier<int> counter2 = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return MultiNotifierBuilder(
      listenables: [counter1, counter2],
      builder: (context, child) {
        return Text('Counters: ${counter1.value} and ${counter2.value}');
      },
    );
  }
}
```

### API Reference

#### AsyncController Management

- `AsyncController<T>`: A controller class for managing asynchronous states and events. Provides methods to handle asynchronous events and update states accordingly..
- `AsyncEmitter<T>`: A custom callback for asynchronous event emission. Used to notifier a state of Controller.
- `AsyncEvent<T>`:  A base abstract class for asynchronous events. Has a method `handle(AsyncEmitter<T> emit)` to handle event. 
- `AsyncState`: A base abstract class for asynchronous states. Used to create multiple states.
- `PendingState<E extends AsyncEvent>`: State representing that an asynchronous operation is pending. Provides params `AsyncEvent? event`.
- `SuccessState<E extends AsyncEvent, T>`: State representing a successful asynchronous operation with data. Provides params `T data` and `AsyncEvent? event`.
- `FailureState<E extends AsyncEvent, T>`: State representing a failed asynchronous operation. Provides params `Object error` and `AsyncEvent? event`.

#### Singleton

- `T instance<T>(T Function() createFunction, [String? name])`: Retrieves an existing singleton instance or creates a new one.
- `T singleton<T>(T Function() createFunction, [String? name])`: Shorthand function for creating or retrieving a singleton instance.

#### Notifier Widgets

- `NotifierBuilder`: A widget that rebuilds when a `Listenable` changes.
- `NotifierListener`: A widget that listens to a `Listenable` and triggers a callback when it changes.
- `MultiNotifierBuilder`: A widget that rebuilds when any of the provided `Listenable` objects change.
- `MultiNotifierListener`: A widget that listens to multiple `Listenable` objects and triggers a callback when any of them change.

### Contributing

We welcome contributions! Please read our [contributing guidelines](CONTRIBUTING.md) and feel free to submit pull requests.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Acknowledgements

Special thanks to the Flutter community for their support and contributions.

---

Start making your Flutter applications more reactive and maintainable with `listenable_tools`! If you have any questions or feedback, please open an issue or reach out to us. Happy coding!