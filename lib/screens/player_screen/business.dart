import 'dart:async';

import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

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

    // UI
    _showDanmakuControlNotifier.addListener(
      () => getIt<Toast>().setOffset(
          _showDanmakuControlNotifier.value ? PlayerScreen.danmakuHeight : 0),
    );
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _panelNotifier),
        ValueListenableProxyProvider(
          valueListenable: _showDanmakuControlNotifier,
          proxy: (value) => DanmakuVisible(value),
        ),
      ],
      child: child?.actions(
        actions: {
          ShowPanelIntent: ShowPanelAction(widgetNotifier: _panelNotifier),
          ClosePanelIntent: ClosePanelAction(widgetNotifier: _panelNotifier),
          ToggleDanmakuControlIntent: ToggleDanmakuControlAction(
              showDanmakuControlNotifier: _showDanmakuControlNotifier),
        },
      ),
    );
  }

  @override
  void dispose() {
    _panelNotifier.dispose();
    _showDanmakuControlNotifier.dispose();
    super.dispose();
  }
}

class PlayScreenBusiness extends SingleChildStatefulWidget {
  const PlayScreenBusiness({super.key, super.child});

  @override
  State<PlayScreenBusiness> createState() => _PlayScreenBusinessState();
}

class _PlayScreenBusinessState extends SingleChildState<PlayScreenBusiness> {
  // Intent that try to join channel
  ShareVideoIntent? _initShareIntent;
  final _isJoiningChannelNotifier = ValueNotifier(false)
    ..watchInConsole('In Channel');
  final _childKey = GlobalKey();
  BuildContext get _childContext => _childKey.currentState!.context;

  @override
  void initState() {
    super.initState();

    // Things when joining channel
    _isJoiningChannelNotifier.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_initShareIntent != null) {
          Actions.invoke(_childContext, _initShareIntent!);
        } else {
          Actions.invoke(_childContext, AskPositionIntent());
        }
      });
    });

    // Play video from route argument
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final argument = ModalRoute.of(context)?.settings.arguments;
      if (argument is OpenVideoDialogResult) {
        // Join in by open video from dialog
        final act = Actions.invoke(
          _childContext,
          OpenVideoIntent.url(argument.url),
        ) as Future;
        final payload = await act;

        if (mounted && !argument.onlyForMe) {
          Actions.invoke(
            _childContext,
            ShareVideoIntent(payload.record),
          );
        }
      } else if (argument is VideoRecord) {
        // Join in by "Channel Card" in Welcome screen
        final act = Actions.invoke(
          _childContext,
          OpenVideoIntent.record(argument),
        ) as Future;
        await act;

        if (!mounted) return;
        _isJoiningChannelNotifier.value = true;
      }
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final widget = _WidgetBusiness(key: _childKey, child: child);

    final channelWrap = ValueListenableBuilder(
      valueListenable: _isJoiningChannelNotifier,
      builder: (context, isJoining, child) => isJoining
          ? widget
              .danmakuBusiness()
              .playSyncBusiness()
              .channelBusiness()
              .voiceCallBusiness()
          : Actions(
              actions: {
                ShareVideoIntent: CallbackAction<ShareVideoIntent>(
                  onInvoke: (intent) {
                    _initShareIntent = intent;
                    _isJoiningChannelNotifier.value = true;
                    return null;
                  },
                )
              },
              child: widget,
            ),
    );

    return ValueListenableProxyProvider(
      valueListenable: _isJoiningChannelNotifier,
      proxy: (value) => IsInChannel(value),
      child: channelWrap.playBusiness(),
    );
  }

  @override
  void dispose() {
    _isJoiningChannelNotifier.dispose();
    super.dispose();
  }
}

extension WrapPlayScreenBusiness on Widget {
  Widget playScreenBusiness({Key? key}) =>
      PlayScreenBusiness(key: key, child: this);
}
