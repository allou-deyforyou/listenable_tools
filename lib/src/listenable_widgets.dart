import 'package:flutter/widgets.dart';

typedef ListenableWidgetListener = void Function(BuildContext context);

typedef ListenableCanCallBack = bool Function();

typedef ListenableWidgetBuilder = Widget Function(BuildContext context, Widget? child);

class ListenableBuilder extends StatefulWidget {
  const ListenableBuilder({
    super.key,
    required this.listenable,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final Listenable listenable;
  final ListenableWidgetBuilder builder;
  final ListenableCanCallBack? canRebuild;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _ListenableBuilderState();
}

class _ListenableBuilderState extends State<ListenableBuilder> {
  void _initValueState() {
    widget.listenable.addListener(_valueChanged);
  }

  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call();
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
  void didUpdateWidget(ListenableBuilder oldWidget) {
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
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}

class ListenableListener extends StatefulWidget {
  const ListenableListener({
    super.key,
    required this.listenable,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final Listenable listenable;
  final ListenableWidgetListener listener;
  final ListenableCanCallBack? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _ListenableListenerState();
}

class _ListenableListenerState extends State<ListenableListener> {
  void _initValueState() {
    if (widget.autoListen) _valueChanged();
    widget.listenable.addListener(_valueChanged);
  }

  bool _canListen() {
    final canListen = widget.canListen?.call();
    return canListen == null || canListen;
  }

  void _valueChanged() {
    if (_canListen()) {
      widget.listener(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(ListenableListener oldWidget) {
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

class ListenableConsumer extends StatelessWidget {
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

  final Listenable listenable;
  final ListenableWidgetListener listener;
  final ListenableCanCallBack? canRebuild;
  final ListenableCanCallBack? canListen;
  final ListenableWidgetBuilder builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableListener(
      listenable: listenable,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: ListenableBuilder(
        listenable: listenable,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}

class MultiListenableBuilder extends StatelessWidget {
  const MultiListenableBuilder({
    super.key,
    required this.listenables,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final List<Listenable> listenables;
  final ListenableWidgetBuilder builder;
  final ListenableCanCallBack? canRebuild;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      canRebuild: canRebuild,
      builder: builder,
      child: child,
    );
  }
}

class MultiListenableListener extends StatelessWidget {
  const MultiListenableListener({
    super.key,
    required this.listenables,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final List<Listenable> listenables;
  final ListenableWidgetListener listener;
  final ListenableCanCallBack? canListen;
  final bool autoListen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return listenables.fold(child, (child, listenable) {
      return ListenableListener(
        listenable: listenable,
        autoListen: autoListen,
        canListen: canListen,
        listener: listener,
        child: child,
      );
    });
  }
}

class MultiListenableConsumer extends StatelessWidget {
  const MultiListenableConsumer({
    super.key,
    required this.listenables,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final List<Listenable> listenables;
  final ListenableWidgetListener listener;
  final ListenableCanCallBack? canRebuild;
  final ListenableCanCallBack? canListen;
  final ListenableWidgetBuilder builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiListenableListener(
      listenables: listenables,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: MultiListenableBuilder(
        listenables: listenables,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}
