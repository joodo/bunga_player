import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class SetFullScreenIntent extends Intent {
  const SetFullScreenIntent(this.isFullScreen);
  final bool isFullScreen;
}

class SetFullScreenAction extends ContextAction<SetFullScreenIntent> {
  @override
  void invoke(SetFullScreenIntent intent, [BuildContext? context]) {
    final read = context!.read;

    read<IsFullScreen>().value = intent.isFullScreen;
    context.read<ShouldShowHUD>().mark(keep: !intent.isFullScreen);
  }
}

class SetWindowTitleIntent extends Intent {
  final String? title;

  const SetWindowTitleIntent([this.title]);
}

class SetWindowTitleAction extends Action<SetWindowTitleIntent> {
  @override
  Future<void> invoke(SetWindowTitleIntent intent) {
    return windowManager.setTitle(intent.title ?? '👍 棒嘎大影院，你我来相见');
  }
}

class UIActions extends StatelessWidget {
  final Widget child;
  UIActions({super.key, required this.child}) {
    SetWindowTitleAction().invoke(const SetWindowTitleIntent());
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): SetFullScreenIntent(false),
      },
      child: child,
    );

    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'ui'),
      actions: <Type, Action<Intent>>{
        SetFullScreenIntent: SetFullScreenAction(),
        SetWindowTitleIntent: SetWindowTitleAction(),
      },
      child: shortcuts,
    );
  }
}
