import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

// Callback function that takes a BuildContext and a generic value as parameters
typedef ValueWidgetListener<T> = void Function(BuildContext context, T value);

// Callback function that takes two generic values and returns a boolean
typedef ValueCanCallBack<T> = bool Function(T previousState, T currentState);

// A widget that rebuilds when the value of a ValueListenable<T> changes
class ControllerBuilder<T> extends StatefulWidget {
  const ControllerBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.autoListen = false,
    this.canRebuild,
    this.canListen,
    this.listener,
    this.child,
  });

  final ValueListenable<T> controller;
  final ValueWidgetListener<T>? listener;
  final ValueWidgetBuilder<T> builder;
  final ValueCanCallBack<T>? canRebuild;
  final ValueCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ControllerBuilderState<T>();
}

class _ControllerBuilderState<T> extends State<ControllerBuilder<T>> {
  late T _value;

  // Initialize the state with the initial value of the controller
  void _initValueState() {
    _value = widget.controller.value;

    // Listen to changes if autoListen is true
    if (widget.autoListen) _changeListenerValue();

    // Add a listener to the controller
    widget.controller.addListener(_valueChanged);
  }

  // Check if the widget can be rebuilt
  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call(_value, widget.controller.value);
    return canRebuild == null || canRebuild;
  }

  // Check if the widget can listen
  bool _canListen() {
    final canListen = widget.canListen?.call(_value, widget.controller.value);
    return canListen == null || canListen;
  }

  // Callback function called when the controller value changes
  void _valueChanged() {
    // Update the local value with the new value from the controller
    _value = widget.controller.value;

    _changeListenerValue();

    _changeBuilderValue();
  }

  // Callback function called when the controller value changes
  void _changeListenerValue() {
    // Trigger the listener callback if allowed
    if (_canListen()) widget.listener?.call(context, _value);
  }

  // Callback function called when the controller value changes
  void _changeBuilderValue() {
    // Rebuild the widget if allowed
    if (_canRebuild()) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ControllerBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the controller and remove the old listener
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.controller.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, widget.child);
}

// A widget that listens to a ValueListenable<T> and triggers a callback when the value changes
class ControllerListener<T> extends StatefulWidget {
  const ControllerListener({
    super.key,
    required this.controller,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final ValueListenable<T> controller;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _ControllerListenerState<T>();
}

class _ControllerListenerState<T> extends State<ControllerListener<T>> {
  late T _value;

  // Initialize the state with the initial value of the controller
  void _initValueState() {
    _value = widget.controller.value;

    // Listen to changes if autoListen is true
    if (widget.autoListen) _valueChanged();

    // Add a listener to the controller
    widget.controller.addListener(_valueChanged);
  }

  // Check if the widget can listen
  bool _canListen() {
    final canListen = widget.canListen?.call(_value, widget.controller.value);
    return canListen == null || canListen;
  }

  // Callback function called when the controller value changes
  void _valueChanged() {
    // Update the local value with the new value from the controller
    if (_canListen()) {
      widget.listener(context, _value = widget.controller.value);
    }
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ControllerListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the controller and remove the old listener
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.controller.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// A widget that listens to multiple controllers and triggers a callback when any of them changes
class MultiControllerListener<T> extends StatelessWidget {
  const MultiControllerListener({
    super.key,
    required this.controllers,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final List<ValueListenable<T>> controllers;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Use fold to combine multiple ControllerListeners
    return controllers.fold(child, (child, controller) {
      return ControllerListener<T>(
        controller: controller,
        autoListen: autoListen,
        canListen: canListen,
        listener: listener,
        child: child,
      );
    });
  }
}
