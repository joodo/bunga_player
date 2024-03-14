import 'dart:async';

import 'package:async/async.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/screens/wrappers/actions.dart';
import 'package:bunga_player/services/call.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class CallingRequestBusiness {
  CallingRequestBusiness(this._read);
  final Locator _read;

  String? requestMessageId;
  final List<String> myHopeList = [];

  late final requestTimeOutTimer = RestartableTimer(
    const Duration(seconds: 20),
    () {
      getIt<Toast>().show('无人接听');
      Actions.maybeInvoke(
        Intentor.context,
        CancelCallingRequestIntent(),
      );
    },
  )..cancel();

  Future<void> myRequestHasBeenAccepted() {
    _read<CurrentCallStatus>().value = CallStatus.talking;
    requestMessageId = null;
    myHopeList.clear();
    requestTimeOutTimer.cancel();

    return joinChannel();
  }

  void myRequestIsRejectedBy(User user) {
    myHopeList.remove(user.id);

    logger
        .i('${user.id} rejected call asking or leaved, hope list: $myHopeList');

    if (myHopeList.isEmpty) {
      getIt<Toast>().show('呼叫已被拒绝');
      Actions.invoke(
        Intentor.context,
        CancelCallingRequestIntent(),
      );
    }
  }

  StreamSubscription? _talkersCountSubscription;
  Future<void> joinChannel() async {
    final agoraService = getIt<CallService>();
    final stream = await agoraService.joinChannel();
    _talkersCountSubscription =
        stream.listen((count) => _read<CurrentTalkersCount>().value = count);
  }

  Future<void> leaveChannel() async {
    final agoraService = getIt<CallService>();
    await _talkersCountSubscription!.cancel();
    return agoraService.leaveChannel();
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

    read<CurrentCallStatus>().value = CallStatus.callOut;

    final message =
        await (Actions.invoke(context, const SendMessageIntent('call ask'))
            as Future<Message>);

    callingRequestBusiness.requestMessageId = message.id;
    callingRequestBusiness.myHopeList
        .addAll(read<CurrentChannelWatchers>().value.map((user) => user.id));
    callingRequestBusiness.myHopeList
        .removeWhere((id) => id == read<CurrentUser>().value!.id);
    logger.i(
        'start call asking, hope list: ${callingRequestBusiness.myHopeList}');

    callingRequestBusiness.requestTimeOutTimer.reset();
  }

  @override
  bool isEnabled(StartCallingRequestIntent intent, [BuildContext? context]) {
    return context?.read<CurrentChannelId>().value != null;
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

    await (Actions.invoke(
        context,
        SendMessageIntent(
          'call cancel',
          quoteId: callingRequestBusiness.requestMessageId,
        )) as Future<Message>);

    callingRequestBusiness.myHopeList.clear();
    callingRequestBusiness.requestMessageId = null;
    callingRequestBusiness.requestTimeOutTimer.cancel();

    read<CurrentCallStatus>().value = CallStatus.none;
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

    await (Actions.invoke(
      context,
      SendMessageIntent(
        'call no',
        quoteId: callingRequestBusiness.requestMessageId,
      ),
    ) as Future<Message>);

    callingRequestBusiness.requestMessageId = null;

    read<CurrentCallStatus>().value = CallStatus.none;
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

    await (Actions.invoke(
      context,
      SendMessageIntent(
        'call yes',
        quoteId: callingRequestBusiness.requestMessageId,
      ),
    ) as Future<Message>);

    callingRequestBusiness.requestMessageId = null;

    read<CurrentCallStatus>().value = CallStatus.talking;

    callingRequestBusiness.joinChannel();
  }
}

class HangUpIntent extends Intent {}

class HangUpAction extends ContextAction<HangUpIntent> {
  final CallingRequestBusiness callingRequestBusiness;
  HangUpAction({required this.callingRequestBusiness});

  @override
  Future<void>? invoke(HangUpIntent intent, [BuildContext? context]) {
    context!.read<CurrentCallStatus>().value = CallStatus.none;
    AudioPlayer().play(AssetSource('sounds/hang_up.wav'));

    Actions.invoke(context, const MuteMicIntent(false));
    return callingRequestBusiness.leaveChannel();
  }

  @override
  bool isEnabled(HangUpIntent intent, [BuildContext? context]) {
    return context!.read<CurrentCallStatus>().value != CallStatus.none;
  }
}

class MuteMicIntent extends Intent {
  final bool mute;
  const MuteMicIntent(this.mute);
}

class MuteMicAction extends ContextAction<MuteMicIntent> {
  @override
  Future<void> invoke(MuteMicIntent intent, [BuildContext? context]) {
    context!.read<MuteMic>().value = intent.mute;
    return getIt<CallService>().setMuteMic(intent.mute);
  }
}

class VoiceCallActions extends SingleChildStatefulWidget {
  const VoiceCallActions({super.key, super.child});

  @override
  State<VoiceCallActions> createState() => _VoiceCallActionsState();
}

class _VoiceCallActionsState extends SingleChildState<VoiceCallActions> {
  late final _callingRequestBusiness = CallingRequestBusiness(context.read);

  @override
  void initState() {
    final read = context.read;
    read<CurrentCallStatus>().addListener(_soundCallRing);
    read<CurrentTalkersCount>().addListener(_tryAutoHangUp);
    read<CallVolume>().addListener(_applyCallVolume);
    read<CurrentChannelWatchers>().addLeaveListener(_leaveMeansRejectBy);
    read<CurrentChannelMessage>().addListener(_dealResponse);

    super.initState();
  }

  @override
  void dispose() {
    final read = context.read;
    read<CurrentCallStatus>().removeListener(_soundCallRing);
    read<CurrentTalkersCount>().removeListener(_tryAutoHangUp);
    read<CallVolume>().removeListener(_applyCallVolume);
    read<CurrentChannelWatchers>().removeLeaveListener(_leaveMeansRejectBy);
    read<CurrentChannelMessage>().removeListener(_dealResponse);

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Voice call'),
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
        MuteMicIntent: MuteMicAction(),
      },
      child: child!,
    );
  }

  // Call ring
  final _callRinger = AudioPlayer()..setSource(AssetSource('sounds/call.wav'));
  void _soundCallRing() {
    final callStatus = context.read<CurrentCallStatus>().value;
    if (callStatus == CallStatus.callIn || callStatus == CallStatus.callOut) {
      _callRinger.resume();
    } else {
      _callRinger.stop();
    }
  }

  // Auto hang up
  void _tryAutoHangUp() {
    if (context.read<CurrentTalkersCount>().value == 0) {
      getIt<Toast>().show('通话已结束');
      Actions.maybeInvoke(Intentor.context, HangUpIntent());
    }
  }

  // Volume
  void _applyCallVolume() {
    final volumeData = context.read<CallVolume>();

    final setVolume = getIt<CallService>().setVolume;
    if (volumeData.isMute) {
      setVolume(0);
    } else {
      setVolume(volumeData.percent);
    }

    getIt<Preferences>().set('call_volume', volumeData.volume);
  }

  void _leaveMeansRejectBy(User user) {
    if (context.read<CurrentCallStatus>().value == CallStatus.callOut) {
      _callingRequestBusiness.myRequestIsRejectedBy(user);
    }
  }

  void _dealResponse() {
    final read = context.read;

    final message = read<CurrentChannelMessage>().value;
    if (message == null) return;

    if (message.sender.id == read<CurrentUser>().value?.id) return;

    final splits = message.text.split(' ');
    if (splits.first != 'call') return;

    final callStatus = read<CurrentCallStatus>();
    switch (splits[1]) {
      // someone ask for call
      case 'ask':
        switch (callStatus.value) {
          // Has call in
          case CallStatus.none:
            callStatus.value = CallStatus.callIn;
            _callingRequestBusiness.requestMessageId = message.id;

          // Already has call in, no need to deal, current caller will accept
          case CallStatus.callIn:
            break;

          // Some one also want call when I'm calling out, so answer him
          case CallStatus.callOut:
            Actions.invoke(
              Intentor.context,
              SendMessageIntent('call yes', quoteId: message.id),
            );
            _callingRequestBusiness.myRequestHasBeenAccepted();

          // Some one want to join when we are calling, answer him
          case CallStatus.talking:
            Actions.invoke(
              Intentor.context,
              SendMessageIntent('call yes', quoteId: message.id),
            );
        }

      case 'cancel':
        // caller canceled asking
        if (callStatus.value == CallStatus.callIn &&
            message.quoteId == _callingRequestBusiness.requestMessageId) {
          callStatus.value = CallStatus.none;
          _callingRequestBusiness.requestMessageId = null;
        }

      case 'yes':
        // my request has been accepted!
        if (callStatus.value == CallStatus.callOut &&
            message.quoteId == _callingRequestBusiness.requestMessageId) {
          _callingRequestBusiness.myRequestHasBeenAccepted();
        }

      case 'no':
        // someone rejected me
        if (callStatus.value == CallStatus.callOut &&
            message.quoteId == _callingRequestBusiness.requestMessageId) {
          _callingRequestBusiness.myRequestIsRejectedBy(message.sender);
        }

      default:
        logger.w('Unknown call message: $message');
    }
  }
}
