import 'dart:async';

import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/services/permissions.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

enum CallStatus {
  none,
  callIn,
  callOut,
  talking,
}

@immutable
class StartCallingRequestIntent extends Intent {
  final List<String> hopeList;
  const StartCallingRequestIntent({required this.hopeList});
}

class StartCallingRequestAction
    extends ContextAction<StartCallingRequestIntent> {
  final Set<String> hopeList;
  final ValueNotifier<CallStatus> callStatusNotifier;
  final RestartableTimer timeOutTimer;

  StartCallingRequestAction({
    required this.hopeList,
    required this.callStatusNotifier,
    required this.timeOutTimer,
  });

  @override
  void invoke(StartCallingRequestIntent intent, [BuildContext? context]) async {
    callStatusNotifier.value = CallStatus.callOut;
    hopeList.addAll(intent.hopeList);

    final messageData = CallMessageData(action: CallAction.ask);
    Actions.invoke(context!, SendMessageIntent(messageData));

    timeOutTimer.reset();

    logger.i('start call asking, hope list: $hopeList');
  }
}

@immutable
class CancelCallingRequestIntent extends Intent {
  const CancelCallingRequestIntent();
}

class CancelCallingRequestAction
    extends ContextAction<CancelCallingRequestIntent> {
  final Set<String> hopeList;
  final RestartableTimer requestTimeOutTimer;
  final ValueNotifier<CallStatus> callStatusNotifier;

  CancelCallingRequestAction({
    required this.hopeList,
    required this.requestTimeOutTimer,
    required this.callStatusNotifier,
  });

  @override
  void invoke(
    CancelCallingRequestIntent intent, [
    BuildContext? context,
  ]) async {
    final messageData = CallMessageData(action: CallAction.cancel);
    Actions.invoke(context!, SendMessageIntent(messageData));

    hopeList.clear();
    requestTimeOutTimer.cancel();
    callStatusNotifier.value = CallStatus.none;
  }
}

@immutable
class RejectCallingRequestIntent extends Intent {
  const RejectCallingRequestIntent();
}

class RejectCallingRequestAction
    extends ContextAction<RejectCallingRequestIntent> {
  final Set<String> hoperList;
  final ValueNotifier<CallStatus> callStatusNotifier;

  RejectCallingRequestAction({
    required this.hoperList,
    required this.callStatusNotifier,
  });

  @override
  void invoke(
    RejectCallingRequestIntent intent, [
    BuildContext? context,
  ]) {
    final messageData = CallMessageData(action: CallAction.no);
    Actions.invoke(context!, SendMessageIntent(messageData));

    hoperList.clear();

    callStatusNotifier.value = CallStatus.none;
  }
}

@immutable
class AcceptCallingRequestIntent extends Intent {
  const AcceptCallingRequestIntent();
}

class AcceptCallingRequestAction
    extends ContextAction<AcceptCallingRequestIntent> {
  final ValueNotifier<CallStatus> callStatusNotifier;
  final Set<String> hoperList;
  final VoidCallback startTalking;

  AcceptCallingRequestAction({
    required this.callStatusNotifier,
    required this.hoperList,
    required this.startTalking,
  });

  @override
  void invoke(
    AcceptCallingRequestIntent intent, [
    BuildContext? context,
  ]) {
    final messageData = CallMessageData(action: CallAction.yes);
    Actions.invoke(context!, SendMessageIntent(messageData));

    hoperList.clear();

    callStatusNotifier.value = CallStatus.talking;

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
    callStatusNotifier.value = CallStatus.none;
    AudioPlayer().play(
      AssetSource('sounds/hang_up.mp3'),
      mode: PlayerMode.lowLatency,
    );

    stopTalking();
  }
}

class VoiceCallBusiness extends SingleChildStatefulWidget {
  const VoiceCallBusiness({super.key, super.child});

  @override
  State<VoiceCallBusiness> createState() => _VoiceCallBusinessState();
}

class _VoiceCallBusinessState extends SingleChildState<VoiceCallBusiness> {
  final _hopeList = <String>{}; // Who may answer me
  final _hoperList = <String>{}; // Who is asking me
  final _callStatusNotifier = ValueNotifier<CallStatus>(CallStatus.none);

  late final _cancelAction = CancelCallingRequestAction(
    hopeList: _hopeList,
    callStatusNotifier: _callStatusNotifier,
    requestTimeOutTimer: _requestTimeOutTimer,
  );

  late final _requestTimeOutTimer = RestartableTimer(
    const Duration(seconds: 20),
    () {
      getIt<Toast>().show('无人接听');
      final messageData = CallMessageData(action: CallAction.cancel);
      Actions.invoke(context, SendMessageIntent(messageData));

      _hopeList.clear();
      _callStatusNotifier.value = CallStatus.none;
    },
  )..cancel();

  late final StreamSubscription _messageSubscription;

  @override
  void initState() {
    super.initState();

    _callStatusNotifier.addListener(_soundCallRing);

    final myId = context.read<ClientAccount>().id;
    _messageSubscription = context
        .read<Stream<Message>>()
        .where((message) =>
            message.data['type'] == CallMessageData.messageType &&
            message.senderId != myId)
        .map((message) => (
              senderId: message.senderId,
              action: CallMessageData.fromJson(message.data).action,
            ))
        .listen(_dealResponse);
  }

  @override
  void dispose() {
    _callStatusNotifier.dispose();
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        StartCallingRequestIntent: StartCallingRequestAction(
          callStatusNotifier: _callStatusNotifier,
          hopeList: _hopeList,
          timeOutTimer: _requestTimeOutTimer,
        ),
        CancelCallingRequestIntent: _cancelAction,
        RejectCallingRequestIntent: RejectCallingRequestAction(
          hoperList: _hoperList,
          callStatusNotifier: _callStatusNotifier,
        ),
        AcceptCallingRequestIntent: AcceptCallingRequestAction(
          callStatusNotifier: _callStatusNotifier,
          hoperList: _hoperList,
          startTalking: _startTalking,
        ),
        HangUpIntent: HangUpAction(
          callStatusNotifier: _callStatusNotifier,
          stopTalking: _stopTalking,
        ),
      },
      child: MultiProvider(
        providers: [
          ValueListenableProvider.value(value: _callStatusNotifier),
        ],
        child: child,
      ),
    );
  }

  // Call ring
  final _callRinger = AudioPlayer()
    ..setSource(AssetSource('sounds/call.mp3'))
    ..setReleaseMode(ReleaseMode.loop)
    ..setPlayerMode(PlayerMode.lowLatency);
  void _soundCallRing() {
    if (_callStatusNotifier.value == CallStatus.callIn ||
        _callStatusNotifier.value == CallStatus.callOut) {
      _callRinger.resume();
    } else {
      _callRinger.stop();
    }
  }

  void _dealResponse(({String senderId, CallAction action}) data) {
    switch (data.action) {
      // someone ask for call
      case CallAction.ask:
        switch (_callStatusNotifier.value) {
          // Has call in
          case CallStatus.none:
            _callStatusNotifier.value = CallStatus.callIn;
            _hoperList.add(data.senderId);

          // Already has call in
          case CallStatus.callIn:
            _hoperList.add(data.senderId);

          // Some one also want call when I'm calling out, so answer him
          case CallStatus.callOut:
            _acceptAsk();
            _myRequestHasBeenAccepted();

          // Some one want to join when we are calling, answer him
          case CallStatus.talking:
            _acceptAsk();
        }

      case CallAction.cancel:
        // caller canceled asking
        if (_callStatusNotifier.value == CallStatus.callIn) {
          _hoperList.remove(data.senderId);
          if (_hoperList.isEmpty) {
            _callStatusNotifier.value = CallStatus.none;
          }
        }

      case CallAction.yes:
        // my request has been accepted!
        if (_callStatusNotifier.value == CallStatus.callOut) {
          _myRequestHasBeenAccepted();
        }

      case CallAction.no:
        // someone rejected me
        if (_callStatusNotifier.value == CallStatus.callOut) {
          _myRequestIsRejectedBy(data.senderId);
        }
    }
  }

  void _acceptAsk() {
    final messageData = CallMessageData(action: CallAction.yes);
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  void _myRequestIsRejectedBy(String userId) {
    _hopeList.remove(userId);

    logger.i('$userId rejected call asking or leaved, hope list: $_hopeList');

    if (_hopeList.isEmpty) {
      getIt<Toast>().show('呼叫已被拒绝');
      _cancelAction.invoke(
        CancelCallingRequestIntent(),
        context,
      );
    }
  }

  void _myRequestHasBeenAccepted() {
    _hopeList.clear();
    _requestTimeOutTimer.cancel();

    _callStatusNotifier.value = CallStatus.talking;

    _startTalking();
  }

  Future<void> _startTalking() async {
    final myId = context.read<ClientAccount>().id;
    final client = context.read<AgoraClient>();

    await getIt<Permissions>().requestMicrophone();

    await client.joinChannel(userId: myId);

    if (!mounted) return;
    final messageData = TalkStatusMessageData(status: TalkStatus.start);
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  Future<void> _stopTalking() async {
    final messageData = TalkStatusMessageData(status: TalkStatus.end);
    Actions.invoke(context, SendMessageIntent(messageData));

    final client = context.read<AgoraClient>();
    client.micMuteNotifier.value = false;
    await client.leaveChannel();
  }
}

extension WrapVoiceCall on Widget {
  Widget voiceCallBusiness({Key? key}) => VoiceCallBusiness(
        key: key,
        child: this,
      );
}

class VoiceCallGlobalBusiness extends SingleChildStatelessWidget {
  const VoiceCallGlobalBusiness({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ProxyFutureProvider<AgoraClient?, BungaClientInfo?>(
      proxy: (clientInfo) =>
          clientInfo == null ? null : AgoraClient.create(clientInfo),
      initialData: null,
      child: child,
    );
  }
}
