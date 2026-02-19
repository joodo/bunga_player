import 'package:animations/animations.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/screens/dialogs/settings/advanced.dart';
import 'package:bunga_player/screens/dialogs/settings/settings.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<BungaServerInfo?, FetchingBungaClient>(
      builder: (context, clientInfo, fetchingNotifer, child) {
        final failed = !fetchingNotifer.value && clientInfo == null;
        return OpenContainer(
          closedBuilder: (context, openContainer) =>
              OutlinedButton.icon(
                icon:
                    (fetchingNotifer.value
                            ? const LoadingButtonIcon(key: ValueKey('loading'))
                            : clientInfo == null
                            ? const Icon(key: ValueKey('error'), Icons.error)
                            : const Icon(
                                key: ValueKey('settings'),
                                Icons.settings,
                              ))
                        .animatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                        ),
                label:
                    (fetchingNotifer.value
                            ? const Text('正在载入', key: ValueKey('loading'))
                            : Text(
                                clientInfo?.channel.name ?? '设置服务器',
                                key: const ValueKey('finished'),
                              ))
                        .animatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                        )
                        .animatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        ),
                onPressed: openContainer,
              ).colorScheme(
                seedColor: failed ? Colors.red : Colors.green,
                brightness: theme.brightness,
              ),
          closedColor: theme.primaryColor,
          openBuilder: (dialogContext, closeContainer) => Dialog.fullscreen(
            child: SettingsDialog(page: failed ? AdvancedSettings : null),
          ),
          openColor: theme.primaryColor,
        );
      },
    );
  }
}
