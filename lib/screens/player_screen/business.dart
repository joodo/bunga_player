import 'dart:async';

import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'actions.dart';
import 'panel/panel.dart';
import 'player_screen.dart';

@immutable
class DanmakuVisible {
  final bool value;
  const DanmakuVisible(this.value);
}

@immutable
class IsInChannel {
  final bool value;
  const IsInChannel(this.value);
}

class _WidgetBusiness extends SingleChildStatefulWidget {
  const _WidgetBusiness({super.key, super.child});

  @override
  State<_WidgetBusiness> createState() => _WidgetBusinessState();
}

class _WidgetBusinessState extends SingleChildState<_WidgetBusiness> {
  // Panel
  final _panelNotifier = ValueNotifier<Panel?>(null);

  // Danmaku Control
  final _showDanmakuControlNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final popScope = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _resetPlayState();
        Navigator.pop(context);
      },
      child: child!,
    );

    final shortcutsWrap = Consumer<ShortcutMappingNotifier>(
      builder: (context, mappingNotifier, child) {
        final activitor = mappingNotifier.value[ShortcutKey.danmaku];
        return Shortcuts(
          shortcuts: {
            if (activitor != null)
              activitor: const ToggleDanmakuControlIntent(),
          },
          child: child!,
        );
      },
      child: popScope,
    );

    final actionWrap = shortcutsWrap.actions(
      actions: {
        ShowPanelIntent: ShowPanelAction(widgetNotifier: _panelNotifier),
        ClosePanelIntent: ClosePanelAction(widgetNotifier: _panelNotifier),
        ToggleDanmakuControlIntent: ToggleDanmakuControlAction(
          showDanmakuControlNotifier: _showDanmakuControlNotifier,
        ),
      },
    );

    final focusWrap = Focus(autofocus: true, child: actionWrap);

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _panelNotifier),
        ValueListenableProxyProvider(
          valueListenable: _showDanmakuControlNotifier,
          proxy: (value) => DanmakuVisible(value),
        ),
      ],
      child: focusWrap,
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();

    _panelNotifier.dispose();
    _showDanmakuControlNotifier.dispose();
    super.dispose();
  }

  void _resetPlayState() {
    final read = context.read;

    // Stop playing
    read<WindowTitleNotifier>().reset();
    getIt<PlayService>().stop();

    // Send bye message
    if (read<IsInChannel>().value) {
      context.sendMessage(ByeMessageData());
    }

    // Stop talking
    read<AgoraClient?>()?.leaveChannel();
  }
}

class PlayScreenBusiness extends SingleChildStatefulWidget {
  const PlayScreenBusiness({super.key, super.child});

  @override
  State<PlayScreenBusiness> createState() => _PlayScreenBusinessState();
}

class _PlayScreenBusinessState extends SingleChildState<PlayScreenBusiness> {
  final _childKey = GlobalKey();
  BuildContext get _childContext => _childKey.currentState!.context;

  late final bool _isInChannel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dealArgument();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final widget = _WidgetBusiness(key: _childKey, child: child!);

    final channelWrap = _isInChannel
        ? widget
              .danmakuBusiness()
              .playSyncBusiness()
              .channelBusiness()
              .voiceCallBusiness()
        : _wrapJoinInAction(widget);
    final businessWrap = channelWrap.playBusiness();
    final provider = Provider.value(
      value: IsInChannel(_isInChannel),
      child: businessWrap,
    );

    return provider;
  }

  Widget _wrapJoinInAction(Widget child) {
    return Actions(
      actions: {
        JoinInIntent: CallbackAction<JoinInIntent>(
          onInvoke: (intent) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
                settings: RouteSettings(arguments: intent.myRecord),
              ),
            );
            return null;
          },
        ),
      },
      child: child,
    );
  }

  Future<void> _dealArgument() async {
    // Play video from route argument
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is OpenVideoDialogResult) {
      // Join in by open video from dialog
      if (argument.onlyForMe) {
        _isInChannel = false;

        runAfterBuild(
          () =>
              Actions.invoke(_childContext, OpenVideoIntent.url(argument.url)),
        );
      } else {
        _isInChannel = true;
        final videoRecord = await PlayPayloadParser(
          context,
        ).parseUrl(argument.url);

        runAfterBuild(
          () => Actions.invoke(
            _childContext,
            JoinInIntent(myRecord: videoRecord),
          ),
        );
      }
    } else if (argument == null) {
      // Join in by "Channel Card" in Welcome screen
      _isInChannel = true;
      runAfterBuild(() => Actions.invoke(_childContext, JoinInIntent()));
    } else if (argument is VideoRecord) {
      // Join in by "share video to channel" action
      _isInChannel = true;
      runAfterBuild(
        () => Actions.invoke(_childContext, JoinInIntent(myRecord: argument)),
      );
    }
  }
}

extension WrapPlayScreenBusiness on Widget {
  Widget playScreenBusiness({Key? key}) =>
      PlayScreenBusiness(key: key, child: this);
}
