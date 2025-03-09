import 'package:animations/animations.dart';
import 'package:bunga_player/client_info/global_business.dart';
import 'package:bunga_player/screens/dialogs/settings/reaction.dart';
import 'package:bunga_player/screens/dialogs/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class NameButton extends StatelessWidget {
  const NameButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      closedBuilder: (context, openContainer) => TextButton(
        onPressed: openContainer,
        child: Selector<ClientNicknameNotifier, String>(
          selector: (context, notifier) => notifier.value,
          builder: (context, String nickname, child) =>
              Text(nickname.isNotEmpty ? '你好，$nickname' : '如何称呼你？')
                  .textStyle(theme.textTheme.titleMedium!.copyWith(height: 0))
                  .padding(all: 8.0),
        ),
      ),
      closedColor: theme.primaryColor,
      openBuilder: (dialogContext, closeContainer) => const Dialog.fullscreen(
        child: SettingsDialog(page: ReactionSettings),
      ),
      openColor: theme.primaryColor,
    );
  }
}
