import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '/client_info/models/client_account.dart';
import '/play/play.dart';
import '/ui/audio_player.dart';

import 'models/models.dart';
import 'providers.dart';

class ChatBusiness extends SingleChildStatefulWidget {
  const ChatBusiness({
    super.key,
    required Widget super.child,
    required this.watchersNotifier,
  });

  final WatchersNotifier watchersNotifier;

  @override
  State<ChatBusiness> createState() => _ChatBusinessState();
}

class _ChatBusinessState extends SingleChildState<ChatBusiness> {
  late final StreamSubscription _streamSubscription;

  late final _myId = context.read<ClientAccount>().id;

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
          widget.watchersNotifier.setIds(watcherIds);
        default:
          {}
      }
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!;
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  void _handleAloha(User sender) {
    _addWatcher(sender);

    // Server will pause when someone is joining
    if (MediaPlayer.i.playStatusNotifier.value.isPlaying) {
      context.read<PlayToggleVisualSignal>().fire(false);
    }
  }

  void _handleHereAre(List<User> watchers) {
    widget.watchersNotifier.setInfos(watchers);
  }

  void _handleBye(String userId) {
    _removeWatcher(userId);
  }

  void _addWatcher(User user) {
    if (widget.watchersNotifier.upsertInfo(user)) {
      context.read<BungaAudioPlayer>().playSfx('user_join');
    }
  }

  void _removeWatcher(String id) {
    if (widget.watchersNotifier.removeId(id)) {
      context.read<BungaAudioPlayer>().playSfx('user_leave');
    }
  }
}

extension ChatBusinessExtension on Widget {
  Widget chatBusiness({required WatchersNotifier watchersNotifier}) =>
      ChatBusiness(watchersNotifier: watchersNotifier, child: this);
}
