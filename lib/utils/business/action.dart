import 'package:flutter/material.dart';

class PassthroughAction<T extends Intent> extends ContextAction<T> {
  final Action action;
  final BuildContext actionContext;
  final bool invokeAfterParent;

  PassthroughAction({
    required this.action,
    required this.actionContext,
    this.invokeAfterParent = false,
  });

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    if (invokeAfterParent) Actions.invoke(actionContext, intent);

    late final Object? result;
    if (action is ContextAction) {
      result = (action as ContextAction).invoke(intent, context);
    } else {
      result = action.invoke(intent);
    }

    if (!invokeAfterParent) Actions.invoke(actionContext, intent);

    return result;
  }
}

extension PassthroughActionExtension<T extends Intent> on Action<T> {
  Action<T> passthrough(
    BuildContext context, {
    bool invokeAfterParent = true,
  }) {
    return PassthroughAction<T>(
      action: this,
      actionContext: context,
      invokeAfterParent: invokeAfterParent,
    );
  }
}
