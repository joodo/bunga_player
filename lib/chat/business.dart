import 'dart:async';

import 'package:bunga_player/ui/audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/business.dart';

import 'models/message.dart';
import 'models/message_data.dart';
import 'models/user.dart';

// Data types

class Watchers extends Iterable<User> {
  final Iterable<User> iterable;
  const Watchers(this.iterable);

  @override
  Iterator<User> get iterator => iterable.iterator;
}

class WatchersNotifier extends ChangeNotifier
    implements ValueListenable<Watchers> {
  WatchersNotifier();

  final Map<String, User> _data = {};

  void init(User myself) {
    _data.clear();
    upsert(myself);
  }

  void upsert(User user) {
    _data[user.id] = user;
    notifyListeners();
  }

  void removeId(String id) {
    _data.remove(id);
    notifyListeners();
  }

  bool containsId(String id) {
    return _data.containsKey(id);
  }

  @override
  Watchers get value => Watchers(_data.values);
}

@immutable
class TalkerId {
  final String value;
  const TalkerId(this.value);
}

// Actions

@immutable
class RefreshWatchersIntent extends Intent {
  const RefreshWatchersIntent();
}

class RefreshWatchersAction extends ContextAction<RefreshWatchersIntent> {
  final WatchersNotifier watchersNotifier;

  RefreshWatchersAction({required this.watchersNotifier});

  @override
  void invoke(RefreshWatchersIntent intent, [BuildContext? context]) {
    final messageData = AlohaMessageData(user: User.fromContext(context!));
    Actions.invoke(context, SendMessageIntent(messageData));

    watchersNotifier.init(User.fromContext(context));
  }
}

class ChannelBusiness extends SingleChildStatefulWidget {
  const ChannelBusiness({super.key, super.child});

  @override
  State<ChannelBusiness> createState() => _ChannelBusinessState();
}

class _ChannelBusinessState extends SingleChildState<ChannelBusiness> {
  late final StreamSubscription _streamSubscription;

  late final _myId = context.read<ClientAccount>().id;

  // Watchers
  final _watchersNotifier = WatchersNotifier()..watchInConsole('Watchers');
  late final _refreshWatchersAction = RefreshWatchersAction(
    watchersNotifier: _watchersNotifier,
  );

  // Talk
  final _talkerIdsNotifier = ValueNotifier<Set<String>>({})
    ..watchInConsole('Talkers Id');

  // Leave message for app exit
  Future<void> _sendLeaveMessage() {
    final byeData = ByeMessageData(userId: _myId);
    return Actions.invoke(context, SendMessageIntent(byeData)) as Future;
  }

  @override
  void initState() {
    super.initState();

    // Listen to message
    final messageStream = context.read<Stream<Message>>();

    _streamSubscription = messageStream.listen((message) {
      switch (message.data['code']) {
        case AlohaMessageData.messageCode:
          _dealWithAloha(AlohaMessageData.fromJson(message.data));
        case HereAreMessageData.messageCode:
          final watchers = HereAreMessageData.fromJson(message.data).watchers;
          _dealWithHereAre(watchers);
        case ByeMessageData.messageCode:
          if (message.sender.id == _myId) break;
          _dealWithBye(ByeMessageData.fromJson(message.data));
        case TalkStatusMessageData.messageCode:
          _dealWithTalkStatus(
            message.sender.id,
            TalkStatusMessageData.fromJson(message.data).status,
          );
      }
    });

    // Get watchers
    if (!mounted) return;
    _refreshWatchersAction.invoke(const RefreshWatchersIntent(), context);

    // Register leave message sender
    getIt<ExitCallbacks>().add(_sendLeaveMessage);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _watchersNotifier),
        ValueListenableProxyProvider(
          valueListenable: _talkerIdsNotifier,
          proxy: (value) => value.map((e) => TalkerId(e)).toList(),
        ),
      ],
      child: child?.actions(
        actions: {RefreshWatchersIntent: _refreshWatchersAction},
      ),
    );
  }

  @override
  void dispose() {
    _watchersNotifier.dispose();
    _talkerIdsNotifier.dispose();
    _streamSubscription.cancel();
    getIt<ExitCallbacks>().remove(_sendLeaveMessage);
    super.dispose();
  }

  void _dealWithAloha(AlohaMessageData data) {
    _addWatcher(data.user);
  }

  void _dealWithHereAre(List<WatcherInfo> watchers) {
    for (final info in watchers) {
      _addWatcher(info.user);
    }

    /*
    if (data.isTalking && _talkerIdsNotifier.value.add(data.user.id)) {
      _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};
    }*/
  }

  void _dealWithBye(ByeMessageData data) {
    _removeWatcher(data.userId);
    if (_talkerIdsNotifier.value.contains(data.userId)) {
      _dealWithTalkStatus(data.userId, TalkStatus.end);
    }
  }

  void _dealWithTalkStatus(String senderId, TalkStatus status) {
    switch (status) {
      case .start:
        if (_talkerIdsNotifier.value.add(senderId)) {
          _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};
          context.read<BungaAudioPlayer>().playSfx('user_speak');
        }
      case .end:
        if (_talkerIdsNotifier.value.remove(senderId)) {
          _talkerIdsNotifier.value = {..._talkerIdsNotifier.value};

          if (_talkerIdsNotifier.value.length == 1 &&
              _talkerIdsNotifier.value.first == _myId) {
            getIt<Toast>().show('通话已结束');
            Actions.invoke(context, const HangUpIntent());
          }
        }
    }
  }

  void _addWatcher(User user) {
    _watchersNotifier.upsert(user);
    context.read<BungaAudioPlayer>().playSfx('user_join');
  }

  void _removeWatcher(String id) {
    _watchersNotifier.removeId(id);
    context.read<BungaAudioPlayer>().playSfx('user_leave');
  }
}

extension WrapChannelBusiness on Widget {
  Widget channelBusiness() => ChannelBusiness(child: this);
}
