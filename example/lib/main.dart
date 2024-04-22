import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listenable_tools/listenable_tools.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Increment Counter Event
class IncrementCounter extends AsyncEvent<int> {
  const IncrementCounter(this.value);
  final int value;
  @override
  Future<void> handle(AsyncEmitter<int> emit) async {
    emit(value + 1);
  }
}

// Decrement Counter Event
class DecrementCounter extends AsyncEvent<int> {
  const DecrementCounter(this.value);
  final int value;
  @override
  Future<void> handle(AsyncEmitter<int> emit) async {
    emit(value - 1);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = AsyncController<int?>();

  void _showModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hello world"),
          content: const Text("Get Started !"),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("ok"),
            ),
          ],
        );
      },
    );
  }

  // Function to listen counter
  void _listenCounter(BuildContext context, int? counter) {
    if (counter == null) {
      WidgetsBinding.instance.endOfFrame.whenComplete(
        _showModal,
      );
    }
  }

  // Function to increment counter
  void _incrementCounter() {
    _controller.run(IncrementCounter(_controller.value ?? 0));
  }

  // Function to decrement counter
  void _decrementCounter() {
    _controller.run(DecrementCounter(_controller.value ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            ControllerBuilder(
              autoListen: true,
              controller: _controller,
              listener: _listenCounter,
              builder: (context, counter, child) {
                return Text(
                  '${counter ?? 0}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
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
