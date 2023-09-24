import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'controller_widgets.dart';

ValueNotifier<T?> _getController<T>({Type? instanceType}) {
  final instanceName = instanceType.toString();
  if (GetIt.instance.isRegistered<ValueNotifier<T?>>(instanceName: instanceName)) {
    return GetIt.instance<ValueNotifier<T?>>(instanceName: instanceName);
  }
  return GetIt.instance.registerSingleton<ValueNotifier<T?>>(
    dispose: (param) => param.dispose(),
    instanceName: instanceName,
    ValueNotifier<T?>(null),
  );
}

extension AsyncBuildContext on BuildContext {
  void dispatch<T>(AsyncEvent<T> event) {
    event.dispatch(this);
  }
}

abstract class AsyncState {
  const AsyncState();
}

class PendingState extends AsyncState {
  const PendingState();
}

class SuccessState<T> extends AsyncState {
  const SuccessState(this.data);
  final T data;
}

class FailureState<T extends AsyncEvent> extends AsyncState {
  const FailureState({
    required this.code,
    this.event,
  });
  final String code;
  final T? event;
}

abstract class AsyncEvent<T> {
  const AsyncEvent();

  Future<void> dispatch(BuildContext context) {
    final controller = _getController<T>(instanceType: runtimeType);
    return handle(context).forEach((value) => controller.value = value);
  }

  Stream<T> handle(BuildContext context);
}

class AsyncBuilder<T extends AsyncEvent<S>, S> extends StatelessWidget {
  const AsyncBuilder({
    super.key,
    required this.builder,
    this.canRebuild,
    this.child,
  });
  final ValueWidgetBuilder<S?> builder;
  final ValueCanCallBack<S?>? canRebuild;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return ControllerBuilder(
      controller: _getController<S>(instanceType: T),
      canRebuild: canRebuild,
      builder: builder,
      child: child,
    );
  }
}

class AsyncListener<T extends AsyncEvent<S>, S> extends StatelessWidget {
  const AsyncListener({
    super.key,
    this.autoListen = false,
    required this.listener,
    required this.child,
    this.canListen,
  });
  final ValueWidgetListener<S?> listener;
  final ValueCanCallBack<S?>? canListen;
  final bool autoListen;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ControllerListener(
      controller: _getController<S>(instanceType: T),
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: child,
    );
  }
}

class AsyncConsumer<T extends AsyncEvent<S>, S> extends StatelessWidget {
  const AsyncConsumer({
    super.key,
    this.autoListen = false,
    required this.listener,
    required this.builder,
    this.canRebuild,
    this.canListen,
    this.child,
  });
  final ValueWidgetListener<S?> listener;
  final ValueCanCallBack<S?>? canListen;
  final ValueCanCallBack<S?>? canRebuild;
  final ValueWidgetBuilder<S?> builder;
  final bool autoListen;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final controller = _getController<S>(instanceType: T);
    return ControllerListener(
      controller: controller,
      autoListen: autoListen,
      canListen: canListen,
      listener: listener,
      child: ControllerBuilder(
        controller: controller,
        canRebuild: canRebuild,
        builder: builder,
        child: child,
      ),
    );
  }
}
