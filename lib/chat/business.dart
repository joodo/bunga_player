import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/ui/audio_player.dart';

import 'models/models.dart';

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
    upsertInfo(myself);
  }

  final Map<String, User> _infos = {};

  void setInfos(Iterable<User> users) {
    _infos.clear();
    _infos[myself.id] = myself;
    for (var u in users) {
      _infos[u.id] = u;
    }
    notifyListeners();
  }

  bool upsertInfo(User user) {
    if (_infos[user.id] != user) {
      _infos[user.id] = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  final List<String> _ids = [];

  void setIds(List<String> ids) {
    if (listEquals(ids, _ids)) return;

    _ids.clear();
    _ids.addAll(ids);
    notifyListeners();
  }

  bool removeId(String id) {
    if (_ids.remove(id)) {
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  @override
  Watchers get value =>
      Watchers(_infos.values.where((u) => _ids.contains(u.id)));
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

  @override
  void initState() {
    super.initState();

    // Listen to message
    final messageStream = context.read<Stream<Message>>();

    _streamSubscription = messageStream.listen((message) {
      switch (message.data) {
        case AlohaMessageData():
          if (message.sender.id == _myId) break;
          _handleAloha(message.sender);
        case HereAreMessageData(:final watchers):
          _handleHereAre(watchers);
        case ByeMessageData():
          if (message.sender.id == _myId) break;
          _handleBye(message.sender.id);
        case ChannelStatusMessageData(:final watcherIds):
          _watchersNotifier.setIds(watcherIds);
        default:
          {}
      }
    });
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
    super.dispose();
  }

  void _handleAloha(User sender) {
    _addWatcher(sender);

    // Server will pause when someone is joining
    if (MediaPlayer.i.playStatusNotifier.value.isPlaying) {
      context.read<PlayToggleVisualSignal>().fire(PlayPauseOverlayStatus.pause);
    }
  }

  void _handleHereAre(List<User> watchers) {
    _watchersNotifier.setInfos(watchers);
  }

  void _handleBye(String userId) {
    _removeWatcher(userId);
  }

  void _addWatcher(User user) {
    if (_watchersNotifier.upsertInfo(user)) {
      context.read<BungaAudioPlayer>().playSfx('user_join');
    }
  }

  void _removeWatcher(String id) {
    if (_watchersNotifier.removeId(id)) {
      context.read<BungaAudioPlayer>().playSfx('user_leave');
    }
  }
}

extension WrapChannelBusiness on Widget {
  Widget channelBusiness() => ChannelBusiness(child: this);
}
