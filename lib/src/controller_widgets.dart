import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef ValueWidgetListener<T> = void Function(BuildContext context, T value);

typedef ValueCanCallBack<T> = bool Function(T previousState, T currentState);

class ControllerBuilder<T> extends StatefulWidget {
  const ControllerBuilder({
    super.key,
    required this.controller,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final ValueListenable<T> controller;
  final ValueWidgetBuilder<T> builder;
  final ValueCanCallBack<T>? canRebuild;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ControllerBuilderState<T>();
}

class _ControllerBuilderState<T> extends State<ControllerBuilder<T>> {
  late T _value;

  void _initValueState() {
    _value = widget.controller.value;
    widget.controller.addListener(_valueChanged);
  }

  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call(_value, widget.controller.value);
    return canRebuild == null || canRebuild;
  }

  void _valueChanged() {
    if (_canRebuild()) setState(() => _value = widget.controller.value);
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ControllerBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value, widget.child);
}

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

  void _initValueState() {
    _value = widget.controller.value;
    if (widget.autoListen) _valueChanged();
    widget.controller.addListener(_valueChanged);
  }

  bool _canListen() {
    final canListen = widget.canListen?.call(_value, widget.controller.value);
    return canListen == null || canListen;
  }

  void _valueChanged() {
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
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ControllerConsumer<T> extends StatelessWidget {
  const ControllerConsumer({
    super.key,
    required this.controller,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final ValueListenable<T> controller;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final ValueCanCallBack<T>? canRebuild;
  final ValueWidgetBuilder<T> builder;
  final bool autoListen;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ControllerListener<T>(
      controller: controller,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: ControllerBuilder<T>(
        controller: controller,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}

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
