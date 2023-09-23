import 'package:flutter/widgets.dart';

typedef NotifierWidgetListener = void Function(BuildContext context);

typedef NotifierCanCallBack = bool Function();

typedef NotifierWidgetBuilder = Widget Function(BuildContext context, Widget? child);

class NotifierBuilder extends StatefulWidget {
  const NotifierBuilder({
    super.key,
    required this.notifier,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final Listenable notifier;
  final NotifierWidgetBuilder builder;
  final NotifierCanCallBack? canRebuild;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _NotifierBuilderState();
}

class _NotifierBuilderState extends State<NotifierBuilder> {
  void _initValueState() {
    widget.notifier.addListener(_valueChanged);
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
  void didUpdateWidget(NotifierBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}

class NotifierListener extends StatefulWidget {
  const NotifierListener({
    super.key,
    required this.notifier,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final Listenable notifier;
  final NotifierWidgetListener listener;
  final NotifierCanCallBack? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _NotifierListenerState();
}

class _NotifierListenerState extends State<NotifierListener> {
  void _initValueState() {
    if (widget.autoListen) _valueChanged();
    widget.notifier.addListener(_valueChanged);
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
  void didUpdateWidget(NotifierListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_valueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class NotifierConsumer extends StatelessWidget {
  const NotifierConsumer({
    super.key,
    required this.notifier,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final Listenable notifier;
  final NotifierWidgetListener listener;
  final NotifierCanCallBack? canRebuild;
  final NotifierCanCallBack? canListen;
  final NotifierWidgetBuilder builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return NotifierListener(
      notifier: notifier,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: NotifierBuilder(
        notifier: notifier,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}

class MultiNotifierBuilder extends StatelessWidget {
  const MultiNotifierBuilder({
    super.key,
    required this.notifiers,
    required this.builder,
    this.canRebuild,
    this.child,
  });

  final List<Listenable> notifiers;
  final NotifierWidgetBuilder builder;
  final NotifierCanCallBack? canRebuild;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return NotifierBuilder(
      notifier: Listenable.merge(notifiers),
      canRebuild: canRebuild,
      builder: builder,
      child: child,
    );
  }
}

class MultiNotifierListener extends StatelessWidget {
  const MultiNotifierListener({
    super.key,
    required this.notifiers,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final List<Listenable> notifiers;
  final NotifierWidgetListener listener;
  final NotifierCanCallBack? canListen;
  final bool autoListen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return notifiers.fold(child, (child, item) {
      return NotifierListener(
        autoListen: autoListen,
        canListen: canListen,
        listener: listener,
        notifier: item,
        child: child,
      );
    });
  }
}

class MultiNotifierConsumer extends StatelessWidget {
  const MultiNotifierConsumer({
    super.key,
    required this.notifiers,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canListen,
    this.canRebuild,
    this.child,
  });

  final List<Listenable> notifiers;
  final NotifierWidgetListener listener;
  final NotifierCanCallBack? canRebuild;
  final NotifierCanCallBack? canListen;
  final NotifierWidgetBuilder builder;
  final bool autoListen;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MultiNotifierListener(
      notifiers: notifiers,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: MultiNotifierBuilder(
        notifiers: notifiers,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}
