import 'dart:async';

import 'package:animations/animations.dart';
import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/dialogs/online_video_dialog.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/dialogs/others_dialog.dart';
import 'package:bunga_player/screens/dialogs/settings.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/auto_retry.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatIndicator>().title = _title;
    });

    _loginJob.run();
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
            style: MenuStyle(
              elevation: MaterialStateProperty.all(12),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12)),
            ),
            rootOverlay: true,
            alignmentOffset: const Offset(0, 8),
            anchorTapClosesMenu: true,
            builder: (context, controller, child) => FilledButton(
              onPressed: isBusy ? null : controller.open,
              child: const Text('打开视频'),
            ),
            menuChildren: [
              ValueListenableBuilder(
                valueListenable: context.read<AListInitiated>(),
                builder: (context, initiated, child) => mock.MenuItemButton(
                  onPressed: initiated ? _openNetDisk : null,
                  leadingIcon: initiated
                      ? const Icon(Icons.cloud_outlined)
                      : SizedBox.square(
                          dimension: IconTheme.of(context).size,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                  child: const Text('网盘'),
                ),
              ),
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.language_outlined),
                onPressed: _openOnline,
                child: const Text('在线视频'),
              ),
              mock.MenuItemButton(
                leadingIcon: const Icon(Icons.folder_outlined),
                onPressed: _openLocalVideo,
                child: const Text('本地文件  '),
              ),
            ],
          ),
          const SizedBox(width: 16),
          _DelayedCallbackButtonWrapper(
            listenable: context.read<CurrentUser>(),
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

  void _openLocalVideo() async {
    _openChannel(entryGetter: LocalVideoEntryDialog().show);
  }

  void _openOnline() {
    _openChannel(
      entryGetter: () => showModal<VideoEntry?>(
        context: context,
        builder: (context) => const OnlineVideoDialog(),
      ),
    );
  }

  void _openNetDisk() async {
    _openChannel(
      entryGetter: () => showModal<VideoEntry?>(
        context: context,
        builder: (dialogContext) => NetDiskDialog(read: context.read),
      ),
    );
  }

  void _joinOthersChannel() async {
    _openChannel(
      entryGetter: () => showModal<(String, VideoEntry)?>(
        context: context,
        builder: (context) => const OthersDialog(),
      ),
    );
  }

  Future<void> _openChannel({
    required Future Function() entryGetter,
  }) async {
    final result = await entryGetter();
    if (result == null || !mounted) return;

    final navigator = Navigator.of(context);
    final cat = context.read<CatIndicator>();
    try {
      if (result is VideoEntry) {
        final response = Actions.invoke(
          context,
          OpenVideoIntent(videoEntry: result),
        ) as Future?;
        await response;

        cat.title = null;
        await navigator.pushNamed('control:main');
        cat.title = _title;
      } else {
        final response = Actions.invoke(
          context,
          OpenVideoIntent(videoEntry: result.$2),
        ) as Future<void>;
        await response;

        cat.title = null;
        await navigator.pushNamed('control:main', arguments: {
          'channelId': result.$1,
        });
        cat.title = _title;
      }
    } catch (e) {
      getIt<Toast>().show('解析失败');
      rethrow;
    }
  }

  void _onChangeName() async {
    _loginJob.cancelIfNotFinished();
    Actions.maybeInvoke(context, LogoutIntent());
    Navigator.of(context).popAndPushNamed('control:rename');
  }

  String get _title => '${context.read<SettingUserName>().value}, 你好！';

  late final AutoRetryJob _loginJob = AutoRetryJob(
    () => Actions.invoke(context, AutoLoginIntent()) as Future,
    jobName: 'Auto Login',
  );
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
        if (_waiting)
          Builder(builder: (context) {
            final textStyle = DefaultTextStyle.of(context).style;
            return SizedBox.square(
              dimension: textStyle.fontSize,
              child: CircularProgressIndicator(
                color: textStyle.color,
                strokeWidth: 2,
              ),
            );
          }),
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
      closedBuilder: (context, openContainer) => IconButton(
        icon: const Icon(Icons.settings),
        onPressed: openContainer,
      ),
      closedColor: theme.primaryColor,
      closedShape: const CircleBorder(),
      openBuilder: (dialogContext, closeContainer) =>
          SettingsDialog(context.read),
      openColor: theme.primaryColor,
    );
  }
}
