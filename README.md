```markdown
# Flutter Custom Components

This project provides custom Flutter components that can be used to enhance your Flutter applications. The components include customizable builders for working with listenable and notifiable objects, a simple asynchronous state management system, and a singleton pattern implementation.

## Table of Contents

- [ListenableBuilder Customization](#listenablebuilder-customization)
  - [ListenableBuilder Classes](#listenablebuilder-classes)
  - [Usage Example](#usage-example)
- [AsyncState and AsyncController](#asyncstate-and-asynccontroller)
  - [AsyncState Classes](#asyncstate-classes)
  - [AsyncEvent Class](#asyncevent-class)
  - [AsyncController Class](#asynccontroller-class)
  - [Usage Example](#usage-example-1)
- [Singleton Pattern](#singleton-pattern)
  - [Singleton Class](#singleton-class)
  - [Usage Example](#usage-example-2)
- [NotifierBuilder](#notifierbuilder)
  - [NotifierBuilder Classes](#notifierbuilder-classes)
  - [Usage Example](#usage-example-3)
- [Usage Examples](#usage-examples)
- [Contributing](#contributing)
- [License](#license)

## ListenableBuilder Customization

### ListenableBuilder Classes

- **`ListenableBuilder`**: A customizable Flutter widget that rebuilds when a `Listenable` object changes.
- **`_ListenableBuilderState`**: The corresponding state class for `ListenableBuilder`.

### Usage Example

```dart
import 'package:flutter/widgets.dart';

class MyListenable extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

class ListenableBuilderExample extends StatelessWidget {
  final MyListenable myNotifier = MyListenable();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: myNotifier,
      builder: (context, child) {
        return Column(
          children: [
            Text('Counter: ${myNotifier.counter}'),
            ElevatedButton(
              onPressed: () => myNotifier.increment(),
              child: Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}
```

## AsyncState and AsyncController

### AsyncState Classes

- **`InitState`**: Represents the initial state of an asynchronous operation.
- **`PendingState`**: Represents a state indicating that an asynchronous operation is pending.
- **`SubscriptionState<T>`**: Represents a state with a subscribed `Stream`.
- **`SuccessState<T>`**: Represents a state with successful data.
- **`FailureState<T>`**: Represents a state with a failed asynchronous event.

### AsyncEvent Class

- **`AsyncEvent<T>`**: An abstract class representing an asynchronous event.

### AsyncController Class

- **`AsyncController<T>`**: A controller for managing asynchronous states.

### Usage Example

```dart
import 'package:flutter/widgets.dart';

class MyAsyncEvent extends AsyncEvent<int> {
  @override
  Future<void> handle(AsyncEmitter<int> emit) async {
    await Future.delayed(Duration(seconds: 2));
    emit(42);
  }
}

class AsyncControllerExample extends StatelessWidget {
  final AsyncController<int> myController = AsyncController<int>(0);

  @override
  Widget build(BuildContext context) {
    return ControllerBuilder(
      controller: myController,
      builder: (context, data, child) {
        return Column(
          children: [
            Text('Data: $data'),
            ElevatedButton(
              onPressed: () async {
                await myController.run(MyAsyncEvent());
              },
              child: Text('Run Async Event'),
            ),
          ],
        );
      },
    );
  }
}
```

## Singleton Pattern

### Singleton Class

- **`Singleton`**: A simple implementation of the singleton pattern.

### Usage Example

```dart
// ...

class SingletonExample extends StatelessWidget {
  final int mySingletonValue = Singleton.instance(() => 42);

  @override
  Widget build(BuildContext context) {
    return Text('Singleton Value: $mySingletonValue');
  }
}
```

## NotifierBuilder

### NotifierBuilder Classes

- **`NotifierBuilder`**: A customizable Flutter widget similar to `ListenableBuilder` but named to reflect custom notifiers.
- **`_NotifierBuilderState`**: The corresponding state class for `NotifierBuilder`.

### Usage Example

```dart
import 'package:flutter/widgets.dart';

class MyNotifier extends ChangeNotifier {
  bool _enabled = false;

  bool get enabled => _enabled;

  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }
}

class NotifierBuilderExample extends StatelessWidget {
  final MyNotifier myNotifier = MyNotifier();

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      notifier: myNotifier,
      builder: (context, child) {
        return Column(
          children: [
            Text('Enabled: ${myNotifier.enabled}'),
            ElevatedButton(
              onPressed: () => myNotifier.toggle(),
              child: Text('Toggle'),
            ),
          ],
        );
      },
    );
  }
}
```

## Usage Examples

Include additional usage examples or details about integrating these components into your Flutter application.

```
