import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef ValueWidgetListener<T> = void Function(BuildContext context, T value);

typedef ValueCanCallBack<T> = bool Function(T previousState, T currentState);

class ValuelistenableBuilder<T> extends StatefulWidget {
  const ValuelistenableBuilder({
    super.key,
    required this.valueListenable,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetBuilder<T> builder;
  final ValueCanCallBack<T>? canRebuild;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ValuelistenableBuilderState<T>();
}

class _ValuelistenableBuilderState<T> extends State<ValuelistenableBuilder<T>> {
  late T _value;

  void _initValueState() {
    _value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call(_value, widget.valueListenable.value);
    return canRebuild == null || canRebuild;
  }

  void _valueChanged() {
    if (_canRebuild()) setState(() => _value = widget.valueListenable.value);
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ValuelistenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value, widget.child);
}

class ValueListenableListener<T> extends StatefulWidget {
  const ValueListenableListener({
    super.key,
    required this.valueListenable,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _ValueListenableListenerState<T>();
}

class _ValueListenableListenerState<T> extends State<ValueListenableListener<T>> {
  late T _value;

  void _initValueState() {
    _value = widget.valueListenable.value;
    if (widget.autoListen) _valueChanged();
    widget.valueListenable.addListener(_valueChanged);
  }

  bool _canListen() {
    final canListen = widget.canListen?.call(_value, widget.valueListenable.value);
    return canListen == null || canListen;
  }

  void _valueChanged() {
    if (_canListen()) {
      widget.listener(context, _value = widget.valueListenable.value);
    }
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ValueListenableListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ValueListenableConsumer<T> extends StatelessWidget {
  const ValueListenableConsumer({
    super.key,
    required this.valueListenable,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final ValueListenable<T> valueListenable;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final ValueCanCallBack<T>? canRebuild;
  final ValueWidgetBuilder<T> builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableListener<T>(
      valueListenable: valueListenable,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: ValuelistenableBuilder<T>(
        valueListenable: valueListenable,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}
