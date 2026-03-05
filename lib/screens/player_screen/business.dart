import 'dart:async';

import 'package:bunga_player/screens/widgets/back_listener.dart';
import 'package:bunga_player/voice_call/client/client.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/reaction/business.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/business.dart';

import 'actions.dart';
import 'panel/panel.dart';

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
  // ignore: unused_element_parameter
  const _WidgetBusiness({super.key, super.child});

  @override
  State<_WidgetBusiness> createState() => _WidgetBusinessState();
}

class _WidgetBusinessState extends SingleChildState<_WidgetBusiness> {
  // Panel
  final _panelNotifier = ValueNotifier<Panel?>(null);

  // Danmaku Control
  final _showDanmakuControlNotifier = ValueNotifier(false);

  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();

    _showDanmakuControlNotifier.addListener(() {
      if (!_showDanmakuControlNotifier.value) {
        _focusNode.requestFocus();
      }

      final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
      if (_showDanmakuControlNotifier.value) {
        showHUDNotifier.lockUp('danmaku');
      } else {
        showHUDNotifier.unlock('danmaku');
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();

    _panelNotifier.dispose();
    _showDanmakuControlNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final focusWrap = Focus(
      autofocus: true,
      focusNode: _focusNode,
      child: child!,
    );

    final popScope = PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _resetPlayState();
      },
      child: focusWrap,
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

    final backWrap = actionWrap.onBack(_onBack);

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _panelNotifier),
        ValueListenableProxyProvider(
          valueListenable: _showDanmakuControlNotifier,
          proxy: (value) => DanmakuVisible(value),
        ),
      ],
      child: backWrap,
    );
  }

  Future<bool> _onBack() async {
    if (_panelNotifier.value != null) {
      ClosePanelAction(
        widgetNotifier: _panelNotifier,
      ).invoke(ClosePanelIntent());
      return true;
    } else {
      return false;
    }
  }

  void _resetPlayState() {
    final read = context.read;

    // Stop playing
    MediaPlayer.i.stop();

    // Send bye message
    if (read<IsInChannel>().value) {
      context.sendMessage(ByeMessageData());
    }

    // Stop talking
    read<VoiceCallClient?>()?.leaveChannel();
  }
}

class PlayScreenBusiness extends SingleChildStatefulWidget {
  final BuildContext Function() getChildContext;
  const PlayScreenBusiness({
    super.key,
    super.child,
    required this.getChildContext,
  });

  @override
  State<PlayScreenBusiness> createState() => _PlayScreenBusinessState();
}

enum _Situation { none, local, localToShare, channelJoin, channelShare }

class _PlayScreenBusinessState extends SingleChildState<PlayScreenBusiness> {
  _Situation _situation = .none;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_situation == .none) _handleRouteArgument();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final widget = _WidgetBusiness(child: child!);

    final isInChannel = _situation != .local;
    final channelWrap = isInChannel
        ? widget
              .reactionBusiness()
              .playSyncBusiness()
              .channelBusiness()
              .voiceCallBusiness()
        : _wrapJoinInAction(widget);
    final businessWrap = channelWrap.playBusiness();
    final provider = Provider.value(
      value: IsInChannel(isInChannel),
      child: businessWrap,
    );

    return provider;
  }

  Widget _wrapJoinInAction(Widget child) {
    return Actions(
      actions: {
        JoinInIntent: CallbackAction<JoinInIntent>(
          onInvoke: (intent) => setState(() {
            _situation = .localToShare;
            runAfterBuild(
              () => Actions.invoke(
                widget.getChildContext(),
                JoinInIntent(myRecord: intent.myRecord),
              ),
            );
          }),
        ),
      },
      child: child,
    );
  }

  Future<void> _handleRouteArgument() async {
    // Play video from route argument
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is OpenVideoDialogResult) {
      // Join in by open video from dialog
      if (argument.onlyForMe) {
        _situation = .local;

        runAfterBuild(
          () => Actions.invoke(
            widget.getChildContext(),
            OpenVideoIntent.url(argument.url),
          ),
        );
      } else {
        _situation = .channelShare;
        final videoRecord = await PlayPayloadParser(
          context,
        ).parseUrl(argument.url);

        runAfterBuild(
          () => Actions.invoke(
            widget.getChildContext(),
            JoinInIntent(myRecord: videoRecord),
          ),
        );
      }
    } else if (argument == null) {
      // Join in by "Channel Card" in Welcome screen
      _situation = .channelJoin;
      runAfterBuild(
        () => Actions.invoke(widget.getChildContext(), JoinInIntent()),
      );
    }
  }
}

extension WrapPlayScreenBusiness on Widget {
  Widget playScreenBusiness({
    Key? key,
    required BuildContext Function() getChildContext,
  }) => PlayScreenBusiness(
    key: key,
    getChildContext: getChildContext,
    child: this,
  );
}
