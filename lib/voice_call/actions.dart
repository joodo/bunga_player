import 'dart:async';

import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:bunga_player/voice_call/client/client.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'providers.dart';

class CallingRequestBusiness {
  final Locator providerLocator;
  CallingRequestBusiness({required this.providerLocator});

  String? requestMessageId;
  final List<String> myHopeList = [];

  late final requestTimeOutTimer = RestartableTimer(
    const Duration(seconds: 20),
    () {
      getIt<Toast>().show('无人接听');
      providerLocator<ActionsLeaf>().mayBeInvoke(CancelCallingRequestIntent());
    },
  )..cancel();

  void myRequestIsRejectedBy(User user) {
    myHopeList.remove(user.id);

    logger
        .i('${user.id} rejected call asking or leaved, hope list: $myHopeList');

    if (myHopeList.isEmpty) {
      getIt<Toast>().show('呼叫已被拒绝');
      providerLocator<ActionsLeaf>().mayBeInvoke(CancelCallingRequestIntent());
    }
  }
}

class StartCallingRequestIntent extends Intent {}

class StartCallingRequestAction
    extends ContextAction<StartCallingRequestIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  StartCallingRequestAction({required this.callingRequestBusiness});

  @override
  Future<void>? invoke(StartCallingRequestIntent intent,
      [BuildContext? context]) async {
    final read = context!.read;

    read<VoiceCallStatus>().value = VoiceCallStatusType.callOut;

    final message = await (read<ActionsLeaf>().invoke(
      const SendMessageIntent('call ask'),
    ) as Future<Message>);

    callingRequestBusiness.requestMessageId = message.id;
    callingRequestBusiness.myHopeList
        .addAll(read<ChatChannelWatchers>().value.map((user) => user.id));
    callingRequestBusiness.myHopeList
        .removeWhere((id) => id == read<ChatUser>().value!.id);
    logger.i(
        'start call asking, hope list: ${callingRequestBusiness.myHopeList}');

    callingRequestBusiness.requestTimeOutTimer.reset();
  }

  @override
  bool isEnabled(StartCallingRequestIntent intent, [BuildContext? context]) {
    return context?.read<ChatChannel>().value != null;
  }
}

class CancelCallingRequestIntent extends Intent {}

class CancelCallingRequestAction
    extends ContextAction<CancelCallingRequestIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  CancelCallingRequestAction({required this.callingRequestBusiness});

  @override
  Future<void>? invoke(
    CancelCallingRequestIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;

    await (read<ActionsLeaf>().invoke(
      SendMessageIntent(
        'call cancel',
        quoteId: callingRequestBusiness.requestMessageId,
      ),
    ) as Future<Message>);

    callingRequestBusiness.myHopeList.clear();
    callingRequestBusiness.requestMessageId = null;
    callingRequestBusiness.requestTimeOutTimer.cancel();

    read<VoiceCallStatus>().value = VoiceCallStatusType.none;
  }
}

class RejectCallingRequestIntent extends Intent {}

class RejectCallingRequestAction
    extends ContextAction<RejectCallingRequestIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  RejectCallingRequestAction({required this.callingRequestBusiness});

  @override
  Future<void>? invoke(
    RejectCallingRequestIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;

    await (read<ActionsLeaf>().invoke(
      SendMessageIntent(
        'call no',
        quoteId: callingRequestBusiness.requestMessageId,
      ),
    ) as Future<Message>);

    callingRequestBusiness.requestMessageId = null;

    read<VoiceCallStatus>().value = VoiceCallStatusType.none;
  }
}

class AcceptCallingRequestIntent extends Intent {}

class AcceptCallingRequestAction
    extends ContextAction<AcceptCallingRequestIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  AcceptCallingRequestAction({required this.callingRequestBusiness});

  @override
  Future<void>? invoke(
    AcceptCallingRequestIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;

    await (read<ActionsLeaf>().invoke(
      SendMessageIntent(
        'call yes',
        quoteId: callingRequestBusiness.requestMessageId,
      ),
    ) as Future<Message>);

    callingRequestBusiness.requestMessageId = null;

    read<VoiceCallStatus>().value = VoiceCallStatusType.talking;

    await read<VoiceCallClient>().joinChannel(
      userId: read<ChatUser>().value!.id,
      channelId: read<ChatChannel>().value!.id,
    );
  }
}

class HangUpIntent extends Intent {}

class HangUpAction extends ContextAction<HangUpIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  HangUpAction({required this.callingRequestBusiness});

  @override
  Future<void> invoke(HangUpIntent intent, [BuildContext? context]) async {
    final read = context!.read;

    read<VoiceCallStatus>().value = VoiceCallStatusType.none;
    AudioPlayer().play(AssetSource('sounds/hang_up.wav'));

    read<ActionsLeaf>().invoke(const VoiceCallMuteMicIntent(false));

    await read<VoiceCallClient>().leaveChannel();
    read<VoiceCallTalkers>().clear();
  }

  @override
  bool isEnabled(HangUpIntent intent, [BuildContext? context]) {
    return context!.read<VoiceCallStatus>().value != VoiceCallStatusType.none;
  }
}

class VoiceCallMuteMicIntent extends Intent {
  final bool mute;
  const VoiceCallMuteMicIntent(this.mute);
}

class VoiceCallMuteMicAction extends ContextAction<VoiceCallMuteMicIntent> {
  @override
  Future<void> invoke(VoiceCallMuteMicIntent intent, [BuildContext? context]) {
    context!.read<VoiceCallMuteMic>().value = intent.mute;
    return context.read<VoiceCallClient>().setMuteMic(intent.mute);
  }
}

class VoiceCallActions extends SingleChildStatefulWidget {
  const VoiceCallActions({super.key, super.child});

  @override
  State<VoiceCallActions> createState() => _VoiceCallActionsState();
}

class _VoiceCallActionsState extends SingleChildState<VoiceCallActions> {
  late final _callingRequestBusiness = CallingRequestBusiness(
    providerLocator: context.read,
  );

  late final _callStatus = context.read<VoiceCallStatus>();
  late final _talkers = context.read<VoiceCallTalkers>();
  late final _volume = context.read<VoiceCallVolume>();
  late final _channelWatchers = context.read<ChatChannelWatchers>();
  late final _channelMessage = context.read<ChatChannelLastMessage>();
  late final _nsLevel = context.read<VoiceCallNoiseSuppressionLevel>();

  @override
  void initState() {
    _callStatus.addListener(_soundCallRing);
    _talkers.addListener(_tryAutoHangUp);
    _volume.addListener(_applyCallVolume);
    _nsLevel.addListener(_applyNoiceSuppress);
    _channelWatchers.addLeaveListener(_leaveMeansRejectBy);
    _channelMessage.addListener(_dealResponse);

    super.initState();
  }

  @override
  void dispose() {
    _callStatus.removeListener(_soundCallRing);
    _talkers.removeListener(_tryAutoHangUp);
    _volume.removeListener(_applyCallVolume);
    _nsLevel.removeListener(_applyNoiceSuppress);
    _channelWatchers.removeLeaveListener(_leaveMeansRejectBy);
    _channelMessage.removeListener(_dealResponse);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: <Type, Action<Intent>>{
        StartCallingRequestIntent: StartCallingRequestAction(
            callingRequestBusiness: _callingRequestBusiness),
        CancelCallingRequestIntent: CancelCallingRequestAction(
            callingRequestBusiness: _callingRequestBusiness),
        RejectCallingRequestIntent: RejectCallingRequestAction(
            callingRequestBusiness: _callingRequestBusiness),
        AcceptCallingRequestIntent: AcceptCallingRequestAction(
            callingRequestBusiness: _callingRequestBusiness),
        HangUpIntent:
            HangUpAction(callingRequestBusiness: _callingRequestBusiness),
        VoiceCallMuteMicIntent: VoiceCallMuteMicAction(),
      },
      child: child!,
    );
  }

  // Call ring
  final _callRinger = AudioPlayer()..setSource(AssetSource('sounds/call.wav'));
  void _soundCallRing() {
    if (_callStatus.value == VoiceCallStatusType.callIn ||
        _callStatus.value == VoiceCallStatusType.callOut) {
      _callRinger.resume();
    } else {
      _callRinger.stop();
    }
  }

  // Auto hang up
  void _tryAutoHangUp() {
    if (_talkers.value.isEmpty) {
      getIt<Toast>().show('通话已结束');
      context.read<ActionsLeaf>().mayBeInvoke(HangUpIntent());
    }
  }

  // Volume
  void _applyCallVolume() {
    final setVolume = context.read<VoiceCallClient>().setVolume;
    if (_volume.value.mute) {
      setVolume(0);
    } else {
      setVolume(_volume.value.percent);
    }
  }

  void _applyNoiceSuppress() {
    (context.read<VoiceCallClient>() as AgoraClient)
        .setNoiseSuppression(_nsLevel.value);
  }

  void _leaveMeansRejectBy({required User user}) {
    if (_callStatus.value == VoiceCallStatusType.callOut) {
      _callingRequestBusiness.myRequestIsRejectedBy(user);
    }
  }

  void _dealResponse() {
    final read = context.read;

    final message = _channelMessage.value;
    if (message == null) return;

    if (message.sender.id == read<ChatUser>().value?.id) return;

    final splits = message.text.split(' ');
    if (splits.first != 'call') return;

    switch (splits[1]) {
      // someone ask for call
      case 'ask':
        switch (_callStatus.value) {
          // Has call in
          case VoiceCallStatusType.none:
            _callStatus.value = VoiceCallStatusType.callIn;
            _callingRequestBusiness.requestMessageId = message.id;

          // Already has call in, no need to deal, current caller will accept
          case VoiceCallStatusType.callIn:
            break;

          // Some one also want call when I'm calling out, so answer him
          case VoiceCallStatusType.callOut:
            read<ActionsLeaf>().invoke(
              SendMessageIntent('call yes', quoteId: message.id),
            );
            myRequestHasBeenAccepted();

          // Some one want to join when we are calling, answer him
          case VoiceCallStatusType.talking:
            read<ActionsLeaf>().invoke(
              SendMessageIntent('call yes', quoteId: message.id),
            );
        }

      case 'cancel':
        // caller canceled asking
        if (_callStatus.value == VoiceCallStatusType.callIn &&
            message.quoteId == _callingRequestBusiness.requestMessageId) {
          _callStatus.value = VoiceCallStatusType.none;
          _callingRequestBusiness.requestMessageId = null;
        }

      case 'yes':
        // my request has been accepted!
        if (_callStatus.value == VoiceCallStatusType.callOut &&
            message.quoteId == _callingRequestBusiness.requestMessageId) {
          myRequestHasBeenAccepted();
        }

      case 'no':
        // someone rejected me
        if (_callStatus.value == VoiceCallStatusType.callOut &&
            message.quoteId == _callingRequestBusiness.requestMessageId) {
          _callingRequestBusiness.myRequestIsRejectedBy(message.sender);
        }

      default:
        logger.w('Unknown call message: $message');
    }
  }

  Future<void> myRequestHasBeenAccepted() {
    final read = context.read;

    read<VoiceCallStatus>().value = VoiceCallStatusType.talking;
    _callingRequestBusiness.requestMessageId = null;
    _callingRequestBusiness.myHopeList.clear();
    _callingRequestBusiness.requestTimeOutTimer.cancel();

    return read<VoiceCallClient>().joinChannel(
      userId: read<ChatUser>().value!.id,
      channelId: read<ChatChannel>().value!.id,
    );
  }
}
