import 'package:flutter/widgets.dart';

// A callback function that takes a BuildContext as a parameter
typedef NotifierWidgetListener = void Function(BuildContext context);

// A callback function that returns a boolean
typedef NotifierCanCallBack = bool Function();

// A callback function that takes a BuildContext and a Widget (child) as parameters
typedef NotifierWidgetBuilder = Widget Function(
    BuildContext context, Widget? child);

// A widget that rebuilds when a Listenable changes
class NotifierBuilder extends StatefulWidget {
  const NotifierBuilder({
    super.key,
    required this.listenable,
    required this.builder,
    this.autoListen = false,
    this.canListen,
    this.canRebuild,
    this.listener,
    this.child,
  });

  final Listenable listenable;
  final NotifierWidgetListener? listener;
  final NotifierWidgetBuilder builder;
  final NotifierCanCallBack? canRebuild;
  final NotifierCanCallBack? canListen;
  final bool autoListen;
  final Widget? child;

  @override
  State<StatefulWidget> createState() => _NotifierBuilderState();
}

class _NotifierBuilderState extends State<NotifierBuilder> {
  late ValueNotifier<void> _valueNotifier;

  // Initialize the value state and add a listener to the Listenable
  void _initValueState() {
    _valueNotifier = ValueNotifier<void>(null);

    // Listen to changes if autoListen is true
    if (widget.autoListen) _changeListenerValue();

    widget.listenable.addListener(_valueChanged);
  }

  // Check if the widget can be rebuilt
  bool _canRebuild() {
    final canRebuild = widget.canRebuild?.call();
    return (canRebuild ?? true);
  }

  // Check if the widget can listen
  bool _canListen() {
    final canListen = widget.canListen?.call();
    return (canListen ?? true);
  }

  // Callback function called when the Listenable changes
  void _valueChanged() {
    _changeListenerValue();
    _changeBuilderValue();
  }

  // Callback function called when the controller value changes
  void _changeListenerValue() {
    // Trigger the listener callback if allowed
    if (_canListen()) widget.listener?.call(context);
  }

  // Callback function called when the controller value changes
  void _changeBuilderValue() {
    // Rebuild the widget if allowed
    if (_canRebuild()) {
      _valueNotifier.value = null; // Trigger ValueNotifier update
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initValueState();
  }

  @override
  void didUpdateWidget(NotifierBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the Listenable and remove the old listener
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.listenable.removeListener(_valueChanged);
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);
}

// A widget that listens to a Listenable and triggers a callback when the Listenable changes
class NotifierListener extends StatefulWidget {
  const NotifierListener({
    super.key,
    required this.listenable,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final Listenable listenable;
  final NotifierWidgetListener listener;
  final NotifierCanCallBack? canListen;
  final bool autoListen;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _NotifierListenerState();
}

class _NotifierListenerState extends State<NotifierListener> {
  late ValueNotifier<void> _valueNotifier;

  // Initialize the value state and add a listener to the Listenable
  void _initValueState() {
    _valueNotifier = ValueNotifier<void>(null);

    if (widget.autoListen) _valueChanged();
    widget.listenable.addListener(_valueChanged);
  }

  // Check if the widget can listen
  bool _canListen() {
    final canListen = widget.canListen?.call();
    return (canListen ?? true);
  }

  // Callback function called when the Listenable changes
  void _valueChanged() {
    // Trigger the listener callback if allowed
    if (_canListen()) {
      _valueNotifier.value = null; // Trigger ValueNotifier update
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
    // Update the Listenable and remove the old listener
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_valueChanged);
      _initValueState();
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    widget.listenable.removeListener(_valueChanged);
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// A widget that rebuilds when multiple listenables change
class MultiNotifierBuilder extends StatelessWidget {
  const MultiNotifierBuilder({
    super.key,
    required this.listenables,
    required this.builder,
    this.autoListen = false,
    this.canListen,
    this.canRebuild,
    this.listener,
    this.child,
  });

  final List<Listenable> listenables;
  final NotifierWidgetListener? listener;
  final NotifierWidgetBuilder builder;
  final NotifierCanCallBack? canRebuild;
  final NotifierCanCallBack? canListen;
  final bool autoListen;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Use NotifierBuilder with Listenable.merge to handle multiple listenables
    return NotifierBuilder(
      listenable: Listenable.merge(listenables),
      autoListen: autoListen,
      canRebuild: canRebuild,
      canListen: canListen,
      listener: listener,
      builder: builder,
      child: child,
    );
  }
}

// A widget that listens to multiple listenables and triggers a callback when any of them changes
class MultiNotifierListener extends StatelessWidget {
  const MultiNotifierListener({
    super.key,
    required this.listenables,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });

  final List<Listenable> listenables;
  final NotifierWidgetListener listener;
  final NotifierCanCallBack? canListen;
  final bool autoListen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Use fold to combine multiple NotifierListeners
    return listenables.fold(child, (child, listenable) {
      return NotifierListener(
        listenable: listenable,
        autoListen: autoListen,
        canListen: canListen,
        listener: listener,
        child: child,
      );
    });
  }
}
