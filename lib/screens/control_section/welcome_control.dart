import 'dart:async';

import 'package:animations/animations.dart';
import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/mocks/menu_anchor.dart' as mock;
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/dialogs/online_video_dialog.dart';
import 'package:bunga_player/screens/dialogs/local_video_entry.dart';
import 'package:bunga_player/screens/dialogs/net_disk.dart';
import 'package:bunga_player/screens/dialogs/others_dialog.dart';
import 'package:bunga_player/screens/dialogs/settings.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/auto_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class WelcomeControl extends StatefulWidget {
  const WelcomeControl({super.key});

  @override
  State<WelcomeControl> createState() => _WelcomeControlState();
}

class _WelcomeControlState extends State<WelcomeControl> {
  Completer<void>? _completer;
  void _initBusinessIndicator() {
    User? getCurrentUser() => context.read<CurrentUser>().value;
    final bi = context.read<BusinessIndicator>();

    if (getCurrentUser() == null) {
      bi.run(
        tasks: [
          bi.setTitle('登录中……'),
          (data) async {
            final result = autoRetry(
              () => Actions.invoke(context, AutoLoginIntent()) as Future,
              jobName: 'auto login',
            );
            await result;
            return getCurrentUser()!.name;
          },
          bi.setTitleFromLastTask((lastResult) => '$lastResult, 你好！'),
          (data) {
            _completer = Completer();
            return _completer!.future;
          }
        ],
        showProgress: false,
      );
    } else {
      bi.run(
        tasks: [
          bi.setTitle('${getCurrentUser()!.name}, 你好！'),
          (data) {
            _completer = Completer();
            return _completer!.future;
          }
        ],
        showProgress: false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_initBusinessIndicator);
  }

  @override
  Widget build(BuildContext context) {
    final actions = Selector<BusinessIndicator, bool>(
      selector: (context, bi) => bi.currentProgress != null,
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
    final currentUser = context.read<CurrentUser>();

    final result = await entryGetter();
    if (result == null) return;

    void doOpen() async {
      try {
        if (result is VideoEntry) {
          final response = Actions.invoke(
            Intentor.context,
            OpenVideoIntent(
              videoEntry: result,
              beforeAskingPosition: () => Actions.invoke(
                Intentor.context,
                JoinChannelIntent.byChannelData(
                  ChannelData.fromShare(currentUser.value!, result),
                ),
              ) as Future<void>,
            ),
          ) as Future?;
          await response;
        } else {
          final response = Actions.invoke(
            Intentor.context,
            OpenVideoIntent(
              videoEntry: result.$2,
              beforeAskingPosition: () => Actions.invoke(
                Intentor.context,
                JoinChannelIntent.byId(result.$1),
              ) as Future?,
            ),
          ) as Future<void>;
          await response;
        }

        if (mounted) Navigator.of(context).popAndPushNamed('control:main');
      } catch (e) {
        getIt<Toast>().show('解析失败');
        Future.microtask(_initBusinessIndicator);
        rethrow;
      }
    }

    _completer?.complete();
    Future.microtask(doOpen);
  }

  void _onChangeName() async {
    _completer?.complete();
    Actions.invoke(context, LogoutIntent());
    Navigator.of(context).popAndPushNamed('control:rename');
  }
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
