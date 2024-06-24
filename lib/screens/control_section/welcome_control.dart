import 'dart:async';

import 'package:animations/animations.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/play_sync/models.dart';
import 'package:bunga_player/player/actions.dart';
import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/dialogs/others_dialog.dart';
import 'package:bunga_player/screens/dialogs/settings.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/screens/widgets/video_open_menu_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  late final _shouldShowHudNotifier = context.read<ShouldShowHUD>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatIndicator>().title = _title;

      _shouldShowHudNotifier.lock('welcome control');
    });
  }

  @override
  void dispose() {
    _shouldShowHudNotifier.unlock('welcome control');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = Selector<CatIndicator, bool>(
      selector: (context, bi) => bi.busy,
      builder: (context, isBusy, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            onPressed: isBusy ? null : _onChangeName,
            child: const Text('换个名字'),
          ),
          const SizedBox(width: 16),
          mock.MyMenuAnchor(
            rootOverlay: true,
            alignmentOffset: const Offset(0, 8),
            style: Theme.of(context).menuTheme.style,
            consumeOutsideTap: true,
            builder: (context, controller, child) => FilledButton(
              onPressed: isBusy
                  ? null
                  : () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
              child: const Text('打开视频'),
            ),
            menuChildren: VideoOpenMenuItemsCreator(
              context,
              onVideoOpened: _onVideoOpened,
            ).create(),
          ),
          const SizedBox(width: 16),
          _DelayedCallbackButtonWrapper(
            listenable: context.read<ChatUser>(),
            delaySelector: (value) => value == null,
            builder: (context, buttonChild, onButtonPressed) => FilledButton(
              onPressed: onButtonPressed,
              child: buttonChild,
            ),
            onPressed: isBusy ? null : _joinOthersChannel,
            child: const Text('其他人'),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        actions,
        Positioned(
          right: 16,
          child: _SettingButtonWrapper(),
        ),
      ],
    );
  }

  void _onVideoOpened(BuildContext context, VideoEntry entry) {
    if (context.read<AutoJoinChannel>().value) {
      Actions.invoke(
        context,
        JoinChannelIntent(ChannelJoinByEntryPayload(entry)),
      );
    }

    _onLeaving();
  }

  void _joinOthersChannel() async {
    final result = await showModal<({String id, VideoEntry entry})?>(
      context: context,
      builder: (context) => const OthersDialog(),
    );
    if (result == null || !mounted) return;

    final response = Actions.invoke(
      context,
      OpenVideoIntent(videoEntry: result.entry),
    ) as Future<void>;
    await response;

    if (!mounted) throw Exception('context unmounted');
    Actions.invoke(
      context,
      JoinChannelIntent(ChannelJoinByIdPayload(result.id)),
    );

    _onLeaving();
  }

  void _onLeaving() {
    context.read<CatIndicator>().title = null;
    Navigator.of(context).popAndPushNamed('control:main');
  }

  void _onChangeName() async {
    final notifier = context.read<ClientUserName>();
    final name = notifier.value;

    notifier.value = '';
    Navigator.of(context).popAndPushNamed(
      'control:rename',
      arguments: {'name': name},
    );
  }

  late final _userNameNotifer = context.read<ClientUserName>();
  String get _title => '${_userNameNotifer.value}, 你好！';
}

class _DelayedCallbackButtonWrapper<T> extends SingleChildStatefulWidget {
  final void Function()? onPressed;
  final Widget Function(
    BuildContext context,
    Widget buttonChild,
    Function()? onButtonPressed,
  ) builder;

  final ValueListenable<T> listenable;
  final bool Function(T value) delaySelector;

  const _DelayedCallbackButtonWrapper({
    required this.onPressed,
    required this.listenable,
    required this.builder,
    required this.delaySelector,
    required super.child,
  });

  @override
  State<_DelayedCallbackButtonWrapper> createState() =>
      _DelayedCallbackButtonWrapperState<T>();
}

class _DelayedCallbackButtonWrapperState<T>
    extends SingleChildState<_DelayedCallbackButtonWrapper<T>> {
  bool _waiting = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (_waiting) {
      widget.onPressed?.call();
      setState(() {
        _waiting = false;
      });
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final content = Stack(
      alignment: Alignment.center,
      children: [
        Visibility.maintain(
          visible: !_waiting,
          child: child!,
        ),
        if (_waiting) const LoadingButtonIcon(),
      ],
    );

    return ValueListenableBuilder<T>(
      valueListenable: widget.listenable,
      builder: (context, value, child) {
        final delayed = widget.delaySelector(value);
        final onPressed = delayed
            ? () {
                if (mounted) {
                  setState(() {
                    _waiting = true;
                  });
                }
              }
            : widget.onPressed;
        return widget.builder(context, content, onPressed);
      },
    );
  }
}

class _SettingButtonWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      useRootNavigator: true,
      closedBuilder: (context, openContainer) =>
          Selector2<BungaClient?, PendingBungaHost, bool>(
        selector: (context, client, pending) =>
            client == null && !pending.value,
        builder: (context, failed, child) => IconButton(
          color: failed ? theme.colorScheme.error : null,
          icon: Icon(failed ? Icons.error : Icons.settings),
          onPressed: openContainer,
        ),
      ),
      closedColor: theme.primaryColor,
      closedShape: const CircleBorder(),
      openBuilder: (dialogContext, closeContainer) => const SettingsDialog(),
      openColor: theme.primaryColor,
    );
  }
}
