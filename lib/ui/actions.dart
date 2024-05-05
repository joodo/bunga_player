import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

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

class UIActions extends SingleChildStatefulWidget {
  const UIActions({super.key, super.child});

  @override
  State<UIActions> createState() => _UIActionsState();
}

class _UIActionsState extends SingleChildState<UIActions> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

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

  @override
  void onWindowClose() async {
    await context.read<ExitCallbacks>().runAll();
    await windowManager.destroy();
  }
}
