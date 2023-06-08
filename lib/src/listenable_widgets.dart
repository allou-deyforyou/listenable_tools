import 'package:flutter/widgets.dart';

typedef ListenableWidgetListener<T extends Listenable> = void Function(BuildContext context, T listenable);

typedef ListenableCanCallBack<T extends Listenable> = bool Function(T listenable);

typedef ListenableWidgetBuilder<T extends Listenable> = Widget Function(BuildContext context, T value, Widget? child);

class ListenableBuilder<T extends Listenable> extends StatefulWidget {
  const ListenableBuilder({
    super.key,
    required this.listenable,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final T listenable;
  final ListenableWidgetBuilder<T> builder;
  final ListenableCanCallBack<T>? canRebuild;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ListenableBuilderState<T>();
}

class _ListenableBuilderState<T extends Listenable> extends State<ListenableBuilder<T>> {
  void _initValueState() {
    widget.listenable.addListener(_valueChanged);
  }

  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call(widget.listenable);
    return canRebuild == null || canRebuild;
  }

  void _valueChanged() {
    if (_canRebuild()) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ListenableBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.listenable, widget.child);
}

class ListenableListener<T extends Listenable> extends StatefulWidget {
  const ListenableListener({
    super.key,
    required this.listenable,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final T listenable;
  final ListenableWidgetListener<T> listener;
  final ListenableCanCallBack<T>? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _ListenableListenerState<T>();
}

class _ListenableListenerState<T extends Listenable> extends State<ListenableListener<T>> {
  void _initValueState() {
    if (widget.autoListen) _valueChanged();
    widget.listenable.addListener(_valueChanged);
  }

  bool _canListen() {
    final canListen = widget.canListen?.call(widget.listenable);
    return canListen == null || canListen;
  }

  void _valueChanged() {
    if (_canListen()) {
      widget.listener(context, widget.listenable);
    }
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ListenableListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ListenableConsumer<T extends Listenable> extends StatelessWidget {
  const ListenableConsumer({
    super.key,
    required this.listenable,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final T listenable;
  final ListenableWidgetListener<T> listener;
  final ListenableCanCallBack<T>? canListen;
  final ListenableCanCallBack<T>? canRebuild;
  final ListenableWidgetBuilder<T> builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableListener<T>(
      listenable: listenable,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: ListenableBuilder<T>(
        listenable: listenable,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}
