import 'package:flutter/material.dart';

class LoggingActionDispatcher extends ActionDispatcher {
  final String? prefix;
  LoggingActionDispatcher({this.prefix, this.mute});

  final Set<Type>? mute;

  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    if (mute?.contains(intent.runtimeType) != true) {
      // logger.i('Action: invoke $action($intent)');
    }
    return super.invokeAction(action, intent, context);
  }

  @override
  (bool, Object?) invokeActionIfEnabled(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    if (mute?.contains(intent.runtimeType) != true) {
      // logger.i('Action: invoke $action($intent)');
    }
    return super.invokeActionIfEnabled(action, intent, context);
  }
}
