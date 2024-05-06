import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'providers.dart';

class SetFullScreenIntent extends Intent {
  const SetFullScreenIntent(this.isFullScreen);
  final bool isFullScreen;
}

class SetFullScreenAction extends ContextAction<SetFullScreenIntent> {
  @override
  void invoke(SetFullScreenIntent intent, [BuildContext? context]) {
    final read = context!.read;

    read<IsFullScreen>().value = intent.isFullScreen;
  }
}

class UIActions extends SingleChildStatelessWidget {
  const UIActions({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final shortcuts = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): SetFullScreenIntent(false),
      },
      child: child!,
    );

    return Actions(
      actions: <Type, Action<Intent>>{
        SetFullScreenIntent: SetFullScreenAction(),
      },
      child: shortcuts,
    );
  }
}
