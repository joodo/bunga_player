import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/audio_player.dart';

import 'models/message.dart';
import 'models/message_data.dart';
import 'models/user.dart';

// Data types

class Watchers extends Iterable<User> {
  final Iterable<User> iterable;
  const Watchers(this.iterable);

  @override
  Iterator<User> get iterator => iterable.iterator;

  @override
  String toString() => jsonEncode(map((e) => e.toJson()).toList());
}

class WatchersNotifier extends ChangeNotifier
    implements ValueListenable<Watchers> {
  final User myself;
  WatchersNotifier({required this.myself}) {
    upsert(myself);
  }

  final Map<String, User> _data = {};

  void set(Iterable<User> users) {
    _data.clear();
    _data[myself.id] = myself;
    for (var u in users) {
      _data[u.id] = u;
    }
    notifyListeners();
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

class ChannelBusiness extends SingleChildStatefulWidget {
  const ChannelBusiness({super.key, super.child});

  @override
  State<ChannelBusiness> createState() => _ChannelBusinessState();
}

class _ChannelBusinessState extends SingleChildState<ChannelBusiness> {
  late final StreamSubscription _streamSubscription;

  late final _myId = context.read<ClientAccount>().id;

  // Watchers
  late final _watchersNotifier = WatchersNotifier(myself: User.of(context))
    ..watchInConsole('Watchers');

  // Leave message for app exit
  Future<void> _sendLeaveMessage() {
    return context.sendMessage(ByeMessageData());
  }

  @override
  void initState() {
    super.initState();

    // Listen to message
    final messageStream = context.read<Stream<Message>>();

    _streamSubscription = messageStream.listen((message) {
      switch (message.data['code']) {
        case AlohaMessageData.messageCode:
          _dealWithAloha(message.sender);
        case HereAreMessageData.messageCode:
          final watchers = HereAreMessageData.fromJson(message.data).watchers;
          _dealWithHereAre(watchers);
        case ByeMessageData.messageCode:
          if (message.sender.id == _myId) break;
          _dealWithBye(message.sender.id);
      }
    });

    // Register leave message sender
    getIt<ExitCallbacks>().add(_sendLeaveMessage);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [ValueListenableProvider.value(value: _watchersNotifier)],
      child: child,
    );
  }

  @override
  void dispose() {
    _watchersNotifier.dispose();
    _streamSubscription.cancel();
    getIt<ExitCallbacks>().remove(_sendLeaveMessage);
    super.dispose();
  }

  void _dealWithAloha(User sender) {
    _addWatcher(sender);
  }

  void _dealWithHereAre(List<User> watchers) {
    _watchersNotifier.set(watchers);
  }

  void _dealWithBye(String userId) {
    _removeWatcher(userId);
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
