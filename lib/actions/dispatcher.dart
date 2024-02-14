import 'package:bunga_player/services/logger.dart';
import 'package:flutter/material.dart';

class LoggingActionDispatcher extends ActionDispatcher {
  final String? prefix;
  LoggingActionDispatcher({this.prefix});

  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    logger.i('Action: invoke $action($intent)');
    return super.invokeAction(action, intent, context);
  }

  @override
  (bool, Object?) invokeActionIfEnabled(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    logger.i('Action: invoke $action($intent)');
    return super.invokeActionIfEnabled(action, intent, context);
  }
}
