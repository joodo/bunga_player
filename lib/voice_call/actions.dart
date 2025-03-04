import 'dart:async';

import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/services/permissions.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:bunga_player/voice_call/client/client.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/voice_call/models.dart';
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

  void myRequestIsRejectedBy(String userId) {
    myHopeList.remove(userId);

    logger.i('$userId rejected call asking or leaved, hope list: $myHopeList');

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

    return _startTalking(read);
  }
}

class HangUpIntent extends Intent {
  const HangUpIntent();
}

class HangUpAction extends ContextAction<HangUpIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  HangUpAction({required this.callingRequestBusiness});

  @override
  Future<void> invoke(HangUpIntent intent, [BuildContext? context]) async {
    final read = context!.read;

    read<VoiceCallStatus>().value = VoiceCallStatusType.none;
    AudioPlayer().play(
      AssetSource('sounds/hang_up.mp3'),
      mode: PlayerMode.lowLatency,
    );

    final actionsLeaf = read<ActionsLeaf>();
    actionsLeaf.invoke(const VoiceCallMuteMicIntent(false));

    await read<VoiceCallClient>().leaveChannel();
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

  late final _chatLastMessage = context.read<ChatChannelLastMessage>();
  late final _callStatus = context.read<VoiceCallStatus>();
  late final _volume = context.read<VoiceCallVolume>();
  late final _channelMessage = context.read<ChatChannelLastMessage>();
  late final _nsLevel = context.read<VoiceCallNoiseSuppressionLevel>();

  @override
  void initState() {
    /*
    _chatChannel.addListener(_autoHangUp);
    _chatLastMessage.addListener(_updateTalkers);
    _callStatus.addListener(_soundCallRing);
    _volume.addListener(_applyCallVolume);
    _nsLevel.addListener(_applyNoiceSuppress);
    _channelWatchers.addLeaveListener(_leaveMeansRejectBy);
    _channelMessage.addListener(_dealResponse);
*/
    super.initState();
  }

  @override
  void dispose() {
    _chatLastMessage.removeListener(_updateTalkers);
    _callStatus.removeListener(_soundCallRing);
    _volume.removeListener(_applyCallVolume);
    _nsLevel.removeListener(_applyNoiceSuppress);
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
  final _callRinger = AudioPlayer()
    ..setSource(AssetSource('sounds/call.mp3'))
    ..setReleaseMode(ReleaseMode.loop)
    ..setPlayerMode(PlayerMode.lowLatency);
  void _soundCallRing() {
    if (_callStatus.value == VoiceCallStatusType.callIn ||
        _callStatus.value == VoiceCallStatusType.callOut) {
      _callRinger.resume();
    } else {
      _callRinger.stop();
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

  void _leaveMeansRejectBy({required String userId}) {
    if (_callStatus.value == VoiceCallStatusType.callOut) {
      _callingRequestBusiness.myRequestIsRejectedBy(userId);
    }
  }

  void _dealResponse() {
    final read = context.read;

    final message = _channelMessage.value;
    if (message == null || !message.data.isCallData) return;

    final data = message.data.toCallData();
    switch (data.action) {
      // someone ask for call
      case CallActionType.ask:
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
            myRequestHasBeenAccepted();

          // Some one want to join when we are calling, answer him
          case VoiceCallStatusType.talking:
        }

      case CallActionType.cancel:
        // caller canceled asking
        if (_callStatus.value == VoiceCallStatusType.callIn &&
            data.answerId == _callingRequestBusiness.requestMessageId) {
          _callStatus.value = VoiceCallStatusType.none;
          _callingRequestBusiness.requestMessageId = null;
        }

      case CallActionType.yes:
        // my request has been accepted!
        if (_callStatus.value == VoiceCallStatusType.callOut &&
            data.answerId == _callingRequestBusiness.requestMessageId) {
          myRequestHasBeenAccepted();
        }

      case CallActionType.no:
        // someone rejected me
        if (_callStatus.value == VoiceCallStatusType.callOut &&
            data.answerId == _callingRequestBusiness.requestMessageId) {
          _callingRequestBusiness.myRequestIsRejectedBy(message.senderId);
        }
    }
  }

  Future<void> myRequestHasBeenAccepted() {
    final read = context.read;

    _callingRequestBusiness.requestMessageId = null;
    _callingRequestBusiness.myHopeList.clear();
    _callingRequestBusiness.requestTimeOutTimer.cancel();

    return _startTalking(read);
  }

  void _updateTalkers() {
    final message = _chatLastMessage.value;
    if (message == null) return;

    final talkers = context.read<VoiceCallTalkers>();
    void removeAndCheck() {
      talkers.remove(message.senderId);

      // Only left me
      if (talkers.value!.length == 1) {
        getIt<Toast>().show('通话已结束');
        context.read<ActionsLeaf>().mayBeInvoke(const HangUpIntent());
      }
    }

    if (message.data.isHereIsData && message.data.toHereIsData().isTalking) {
      talkers.add(message.senderId);
    }

    if (message.data.isByeData) {
      removeAndCheck();
    }

    if (message.data.isTalkStatusData) {
      final status = message.data.toTalkStatusData().status;
      if (status == TalkStatusType.start) {
        talkers.add(message.senderId);
      } else {
        removeAndCheck();
      }
    }
  }
}

Future<void> _startTalking(Locator read) async {
  await getIt<Permissions>().requestMicrophone();

  read<VoiceCallStatus>().value = VoiceCallStatusType.talking;
  await read<VoiceCallClient>().joinChannel(
    userId: 'read<ChatUser>().value!.id',
    channelId: 'read<ChatChannel>().value!.id',
  );
}
