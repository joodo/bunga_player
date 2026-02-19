import 'dart:async';

import 'package:async/async.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/services/permissions.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/ui/audio_player.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/shortcuts.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/services/services.dart';

import 'models/message_data.dart';
import 'client/client.agora.dart';

// Data

const _voiceVolumeKey = 'call_volume';

enum CallStatus { none, callIn, callOut, talking }

// Actions

@immutable
class UpdateVoiceVolumeIntent extends Intent {
  final Volume? volume;
  final int? offset;
  final bool save;
  const UpdateVoiceVolumeIntent(this.volume) : offset = null, save = false;
  const UpdateVoiceVolumeIntent.increase(this.offset)
    : volume = null,
      save = true;
  const UpdateVoiceVolumeIntent.save()
    : volume = null,
      offset = null,
      save = true;
}

class UpdateVoiceVolumeAction extends ContextAction<UpdateVoiceVolumeIntent> {
  @override
  Future<void> invoke(
    UpdateVoiceVolumeIntent intent, [
    BuildContext? context,
  ]) async {
    final client = context!.read<AgoraClient>();
    if (intent.volume != null) {
      client.volumeNotifier.value = intent.volume!;
    }
    if (intent.offset != null) {
      final currentVolume = client.volumeNotifier.value;
      final newVolume = Volume(
        volume: (currentVolume.volume + intent.offset!).clamp(
          Volume.min,
          Volume.max,
        ),
      );
      client.volumeNotifier.value = newVolume;
    }
    if (intent.save) {
      getIt<Preferences>().set(
        _voiceVolumeKey,
        client.volumeNotifier.value.volume,
      );
    }
  }

  @override
  bool isEnabled(UpdateVoiceVolumeIntent intent, [BuildContext? context]) {
    return context?.read<CallStatus?>() == .talking;
  }
}

@immutable
class ToggleMicIntent extends Intent {
  const ToggleMicIntent();
}

class ToggleMicAction extends ContextAction<ToggleMicIntent> {
  @override
  void invoke(ToggleMicIntent intent, [BuildContext? context]) {
    final client = context!.read<AgoraClient>();
    client.micMuteNotifier.value = !client.micMuteNotifier.value;
  }

  @override
  bool isEnabled(ToggleMicIntent intent, [BuildContext? context]) {
    return context?.read<CallStatus?>() == .talking;
  }
}

@immutable
class StartCallingRequestIntent extends Intent {
  final List<String> hopeList;
  const StartCallingRequestIntent({required this.hopeList});
}

class StartCallingRequestAction
    extends ContextAction<StartCallingRequestIntent> {
  final ValueNotifier<CallStatus> callStatusNotifier;
  final RestartableTimer timeOutTimer;

  StartCallingRequestAction({
    required this.callStatusNotifier,
    required this.timeOutTimer,
  });

  @override
  void invoke(StartCallingRequestIntent intent, [BuildContext? context]) async {
    callStatusNotifier.value = .callOut;

    context?.sendMessage(CallMessageData(action: .call));

    timeOutTimer.reset();
  }
}

@immutable
class CancelCallingRequestIntent extends Intent {
  const CancelCallingRequestIntent();
}

class CancelCallingRequestAction
    extends ContextAction<CancelCallingRequestIntent> {
  final RestartableTimer requestTimeOutTimer;
  final ValueNotifier<CallStatus> callStatusNotifier;

  CancelCallingRequestAction({
    required this.requestTimeOutTimer,
    required this.callStatusNotifier,
  });

  @override
  void invoke(
    CancelCallingRequestIntent intent, [
    BuildContext? context,
  ]) async {
    context?.sendMessage(CallMessageData(action: .cancel));

    requestTimeOutTimer.cancel();

    callStatusNotifier.value = .none;
  }
}

@immutable
class RejectCallingRequestIntent extends Intent {
  const RejectCallingRequestIntent();
}

class RejectCallingRequestAction
    extends ContextAction<RejectCallingRequestIntent> {
  final ValueNotifier<CallStatus> callStatusNotifier;

  RejectCallingRequestAction({required this.callStatusNotifier});

  @override
  void invoke(RejectCallingRequestIntent intent, [BuildContext? context]) {
    context?.sendMessage(CallMessageData(action: .reject));

    callStatusNotifier.value = .none;
  }
}

@immutable
class AcceptCallingRequestIntent extends Intent {
  const AcceptCallingRequestIntent();
}

@immutable
class TalkerId {
  final String value;
  const TalkerId(this.value);
}

class AcceptCallingRequestAction
    extends ContextAction<AcceptCallingRequestIntent> {
  final ValueNotifier<CallStatus> callStatusNotifier;
  final VoidCallback startTalking;

  AcceptCallingRequestAction({
    required this.callStatusNotifier,
    required this.startTalking,
  });

  @override
  void invoke(AcceptCallingRequestIntent intent, [BuildContext? context]) {
    context?.sendMessage(CallMessageData(action: .accept));

    callStatusNotifier.value = .talking;

    startTalking();
  }
}

@immutable
class HangUpIntent extends Intent {
  const HangUpIntent();
}

class HangUpAction extends ContextAction<HangUpIntent> {
  final ValueNotifier<CallStatus> callStatusNotifier;
  final VoidCallback stopTalking;

  HangUpAction({required this.callStatusNotifier, required this.stopTalking});

  @override
  void invoke(HangUpIntent intent, [BuildContext? context]) {
    callStatusNotifier.value = .none;
    context!.read<BungaAudioPlayer>().playSfx('hang_up');

    stopTalking();
  }
}

// Business

class VoiceCallBusiness extends SingleChildStatefulWidget {
  const VoiceCallBusiness({super.key, super.child});

  @override
  State<VoiceCallBusiness> createState() => _VoiceCallBusinessState();
}

class _VoiceCallBusinessState extends SingleChildState<VoiceCallBusiness> {
  final _talkerIdsNotifier = ValueNotifier<Set<String>>({})
    ..watchInConsole('Talkers Id');

  final _callStatusNotifier = ValueNotifier<CallStatus>(.none);

  late final _requestTimeOutTimer = RestartableTimer(
    const Duration(seconds: 20),
    () {
      context.read<PlaySyncMessageManager>().show('无人接听');
      context.sendMessage(CallMessageData(action: .cancel));
      _callStatusNotifier.value = .none;
    },
  )..cancel();

  late final StreamSubscription _messageSubscription;

  @override
  void initState() {
    super.initState();

    _callStatusNotifier.addListener(_soundCallRing);

    final myId = context.read<ClientAccount>().id;
    _messageSubscription = context.read<Stream<Message>>().listen((message) {
      switch (message.data['code']) {
        case CallMessageData.messageCode:
          if (message.sender.id == myId) break;
          _handleCallAction(
            senderId: message.sender.id,
            action: CallMessageData.fromJson(message.data).action,
          );
        case TalkStatusMessageData.messageCode:
          _handleTalkStatus(
            message.sender.id,
            TalkStatusMessageData.fromJson(message.data).status,
          );
        case ByeMessageData.messageCode:
          _handleTalkStatus(message.sender.id, TalkStatus.end);
      }
    });
  }

  @override
  void dispose() {
    _callStatusNotifier.dispose();
    _talkerIdsNotifier.dispose();
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final shortcuts = child!.applyShortcuts({
      ShortcutKey.voiceVolumeUp: UpdateVoiceVolumeIntent.increase(10),
      ShortcutKey.voiceVolumeDown: UpdateVoiceVolumeIntent.increase(-10),
      ShortcutKey.muteMic: ToggleMicIntent(),
    });

    final actionWrap = shortcuts.actions(
      actions: {
        StartCallingRequestIntent: StartCallingRequestAction(
          callStatusNotifier: _callStatusNotifier,
          timeOutTimer: _requestTimeOutTimer,
        ),
        CancelCallingRequestIntent: CancelCallingRequestAction(
          callStatusNotifier: _callStatusNotifier,
          requestTimeOutTimer: _requestTimeOutTimer,
        ),
        RejectCallingRequestIntent: RejectCallingRequestAction(
          callStatusNotifier: _callStatusNotifier,
        ),
        AcceptCallingRequestIntent: AcceptCallingRequestAction(
          callStatusNotifier: _callStatusNotifier,
          startTalking: _startTalking,
        ),
        HangUpIntent: HangUpAction(
          callStatusNotifier: _callStatusNotifier,
          stopTalking: _stopTalking,
        ),
        UpdateVoiceVolumeIntent: UpdateVoiceVolumeAction(),
        ToggleMicIntent: ToggleMicAction(),
      },
    );

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _callStatusNotifier),
        ValueListenableProxyProvider(
          valueListenable: _talkerIdsNotifier,
          proxy: (value) => value.map((e) => TalkerId(e)).toList(),
        ),
      ],
      child: actionWrap,
    );
  }

  // Call ring
  void _soundCallRing() {
    final player = context.read<BungaAudioPlayer>();
    if (_callStatusNotifier.value == .callIn ||
        _callStatusNotifier.value == .callOut) {
      player.startRing();
    } else {
      player.stopRing();
    }
  }

  void _handleCallAction({
    required String senderId,
    required CallAction action,
  }) {
    switch (action) {
      case .call:
        if (_callStatusNotifier.value == .none) {
          _callStatusNotifier.value = .callIn;
        }

      case .cancel:
        if (_callStatusNotifier.value == .callIn) {
          _callStatusNotifier.value = .none;
        }

      case .accept:
        if (_callStatusNotifier.value == .callOut) {
          _requestTimeOutTimer.cancel();
          _callStatusNotifier.value = .talking;
          _startTalking();
        }

      case .reject:
        if (_callStatusNotifier.value == .callOut) {
          _requestTimeOutTimer.cancel();
          context.read<PlaySyncMessageManager>().show('呼叫已被拒绝');
          _callStatusNotifier.value = .none;
        }
    }
  }

  void _handleTalkStatus(String senderId, TalkStatus status) {
    switch (status) {
      case .start:
        if (_talkerIdsNotifier.value.add(senderId)) {
          _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};
          context.read<BungaAudioPlayer>().playSfx('user_speak');
        }
      case .end:
        if (_talkerIdsNotifier.value.remove(senderId)) {
          _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};

          if (_talkerIdsNotifier.value.length == 1) {
            // Only me is talking
            context.read<PlaySyncMessageManager>().show('通话已结束');

            final action = HangUpAction(
              callStatusNotifier: _callStatusNotifier,
              stopTalking: _stopTalking,
            );
            action.invoke(const HangUpIntent(), context);
          }
        }
    }
  }

  Future<void> _startTalking() async {
    final myId = context.read<ClientAccount>().id;
    final client = context.read<AgoraClient>();

    await getIt<Permissions>().requestMicrophone();

    await client.joinChannel(userId: myId);

    if (!mounted) return;
    context.sendMessage(TalkStatusMessageData(status: .start));
  }

  Future<void> _stopTalking() async {
    context.sendMessage(TalkStatusMessageData(status: .end));

    final client = context.read<AgoraClient>();
    client.micMuteNotifier.value = false;
    await client.leaveChannel();
  }
}

extension WrapVoiceCall on Widget {
  Widget voiceCallBusiness({Key? key}) =>
      VoiceCallBusiness(key: key, child: this);
}

class VoiceCallGlobalBusiness extends SingleChildStatelessWidget {
  const VoiceCallGlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ProxyFutureProvider<BungaServerInfo?, AgoraClient?>(
      create: (info) async {
        if (info == null) return null;
        final client = await AgoraClient.create(info);

        // Load init volume
        client?.volumeNotifier.value = Volume(
          volume: getIt<Preferences>().get(_voiceVolumeKey) ?? Volume.max,
        );

        return client;
      },
      dispose: (previous) => previous?.dispose(),
      lazy: false,
      child: child,
    );
  }
}
