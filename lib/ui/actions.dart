import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/services.dart';
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

class UIActions extends SingleChildStatefulWidget {
  const UIActions({super.key, super.child});

  @override
  State<UIActions> createState() => _UIActionsState();
}

class _UIActionsState extends SingleChildState<UIActions> {
  @override
  void initState() {
    super.initState();

    getIt<ExitCallbacks>().setShutter(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: SizedBox.square(
            dimension: 32,
            child: CircularProgressIndicator(),
          ),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 3500));
    });
  }

  @override
  void dispose() {
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
}
