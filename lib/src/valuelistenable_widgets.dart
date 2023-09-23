import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef ValueWidgetListener<T> = void Function(BuildContext context, T value);

typedef ValueCanCallBack<T> = bool Function(T previousState, T currentState);

class ValueNotifierBuilder<T> extends StatefulWidget {
  const ValueNotifierBuilder({
    super.key,
    required this.valueNotifier,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final ValueListenable<T> valueNotifier;
  final ValueWidgetBuilder<T> builder;
  final ValueCanCallBack<T>? canRebuild;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ValueNotifierBuilderState<T>();
}

class _ValueNotifierBuilderState<T> extends State<ValueNotifierBuilder<T>> {
  late T _value;

  void _initValueState() {
    _value = widget.valueNotifier.value;
    widget.valueNotifier.addListener(_valueChanged);
  }

  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call(_value, widget.valueNotifier.value);
    return canRebuild == null || canRebuild;
  }

  void _valueChanged() {
    if (_canRebuild()) setState(() => _value = widget.valueNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ValueNotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueNotifier != widget.valueNotifier) {
      oldWidget.valueNotifier.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.valueNotifier.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value, widget.child);
}

class ValueNotifierListener<T> extends StatefulWidget {
  const ValueNotifierListener({
    super.key,
    required this.valueNotifier,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final ValueListenable<T> valueNotifier;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _ValueNotifierListenerState<T>();
}

class _ValueNotifierListenerState<T> extends State<ValueNotifierListener<T>> {
  late T _value;

  void _initValueState() {
    _value = widget.valueNotifier.value;
    if (widget.autoListen) _valueChanged();
    widget.valueNotifier.addListener(_valueChanged);
  }

  bool _canListen() {
    final canListen = widget.canListen?.call(_value, widget.valueNotifier.value);
    return canListen == null || canListen;
  }

  void _valueChanged() {
    if (_canListen()) {
      widget.listener(context, _value = widget.valueNotifier.value);
    }
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ValueNotifierListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueNotifier != widget.valueNotifier) {
      oldWidget.valueNotifier.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.valueNotifier.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ValueNotifierConsumer<T> extends StatelessWidget {
  const ValueNotifierConsumer({
    super.key,
    required this.valueNotifier,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final ValueListenable<T> valueNotifier;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final ValueCanCallBack<T>? canRebuild;
  final ValueWidgetBuilder<T> builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueNotifierListener<T>(
      valueNotifier: valueNotifier,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: ValueNotifierBuilder<T>(
        valueNotifier: valueNotifier,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}

class MultiValueNotifierListener<T> extends StatelessWidget {
  const MultiValueNotifierListener({
    super.key,
    required this.valueNotifiers,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final List<ValueListenable<T>> valueNotifiers;
  final ValueWidgetListener<T> listener;
  final ValueCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return valueNotifiers.fold(child, (child, item) {
      return ValueNotifierListener<T>(
        autoListen: autoListen,
        valueNotifier: item,
        canListen: canListen,
        listener: listener,
        child: child,
      );
    });
  }
}
