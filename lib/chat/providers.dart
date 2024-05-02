import 'dart:async';

import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/utils/business/auto_retry.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'client/client.stream_io.dart';
import 'models/channel_data.dart';
import 'models/message.dart';
import 'models/user.dart';
import 'client/client.dart';

// User
class ChatUser extends ValueNotifier<OwnUser?> {
  ChatUser() : super(null);
}

// Channel
sealed class ChannelJoinPayload {
  bool get active;
  ChannelJoinPayload createActive();
}

class ChannelJoinByIdPayload extends ChannelJoinPayload {
  final String id;
  ChannelJoinByIdPayload(this.id, {required this.active});

  @override
  final bool active;
  @override
  ChannelJoinPayload createActive() => ChannelJoinByIdPayload(id, active: true);
}

class ChannelJoinByDataPayload extends ChannelJoinPayload {
  final ChannelData data;
  ChannelJoinByDataPayload(this.data, {required this.active});

  @override
  final bool active;
  @override
  ChannelJoinPayload createActive() =>
      ChannelJoinByDataPayload(data, active: true);
}

class ChatChannelJoinPayload extends ValueNotifier<ChannelJoinPayload?> {
  ChatChannelJoinPayload() : super(null);
}

class ChatChannel extends ValueNotifier<Channel?> with StreamBinding {
  ChatChannel() : super(null);
}

class ChatChannelData extends ValueNotifier<ChannelData?> with StreamBinding {
  ChatChannelData() : super(null);
}

typedef LeaveEventListener = void Function({required User user});
typedef JoinEventListener = void Function({
  required User user,
  required bool isNew,
});

class ChatChannelWatchers extends ChangeNotifier
    implements ValueListenable<List<User>> {
  final List<User> _value = [];
  @override
  List<User> get value => _value;
  void clear() {
    _value.clear();
    notifyListeners();
  }

  // Join
  final List<JoinEventListener> _joinListeners = [];
  void addJoinListener(JoinEventListener listener) {
    _joinListeners.add(listener);
  }

  void removeJoinListener(JoinEventListener listener) {
    _joinListeners.remove(listener);
  }

  void join(JoinEvent event) {
    if (_value.containsId(event.user.id)) return;
    _value.add(event.user);
    notifyListeners();
    for (final listener in _joinListeners) {
      listener(
        user: event.user,
        isNew: event.isNew,
      );
    }
  }

  // Remove
  final List<LeaveEventListener> _leaveListeners = [];
  void addLeaveListener(LeaveEventListener listener) {
    _leaveListeners.add(listener);
  }

  void removeLeaveListener(LeaveEventListener listener) {
    _leaveListeners.remove(listener);
  }

  void leave(User user) {
    _value.removeId(user.id);
    notifyListeners();
    for (final listener in _leaveListeners) {
      listener(user: user);
    }
  }

  final _subscriptions = <StreamSubscription>[];
  bool get isBinded => _subscriptions.isNotEmpty;

  void bind({
    required Stream<JoinEvent> joinStream,
    required Stream<User> leaveStream,
  }) {
    assert(!isBinded);
    _subscriptions.addAll([
      joinStream.listen(join),
      leaveStream.listen(leave),
    ]);
  }

  Future<void> unbind() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}

class ChatChannelLastMessage extends ValueNotifier<Message?>
    with StreamBinding {
  ChatChannelLastMessage() : super(null);
}

class ChatChannelFiles extends ValueNotifier<Iterable<ChannelFile>> {
  ChatChannelFiles() : super([]);

  StreamSubscription? _subscription;
  bool get isBinded => _subscription != null;

  void bind(Stream<ChannelFile> stream) {
    assert(!isBinded);
    _subscription = stream.listen((file) {
      value = [...value, file];
    });
  }

  Future<void> unbind() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

final chatProviders = MultiProvider(providers: [
  // Client
  ProxyProvider<BungaClient?, ChatClient?>(
    update: (context, bungaClient, previous) {
      return bungaClient == null
          ? null
          : StreamIOClient(bungaClient.streamIOClientInfo.appKey);
    },
    lazy: false,
  ),

  // User
  ChangeNotifierProxyProvider3<ChatClient?, ClientUserName, ClientColorHue,
      ChatUser>(
    create: (context) => ChatUser(),
    update: (
      context,
      chatClient,
      userNameNotifier,
      colorHueNotifier,
      previous,
    ) {
      final userName = userNameNotifier.value;
      if (chatClient != null && userName.isNotEmpty) {
        final bungaClient = context.read<BungaClient?>();
        assert(bungaClient != null);

        final job = AutoRetryJob(
          () => chatClient.login(
            context.read<ClientId>().value,
            bungaClient!.streamIOClientInfo.userToken,
            userName,
            colorHue: colorHueNotifier.value,
          ),
          jobName: 'Login',
          alive: () => context.mounted && userNameNotifier.value == userName,
        );
        job.run().then(
          (user) {
            previous!.value = user;
          },
        ).onError((error, stackTrace) => null);
      } else {
        previous!.value?.logout();
        previous.value = null;
      }

      return previous!;
    },
  ),

  // Channel
  ChangeNotifierProvider(
    create: (context) => ChatChannelJoinPayload(),
    lazy: false,
  ),
  ChangeNotifierProxyProvider2<ChatClient?, ChatChannelJoinPayload,
      ChatChannel>(
    create: (context) => ChatChannel(),
    update: (context, chatClient, channelJoinPayload, previous) {
      previous!.value?.leave();
      previous.value = null;

      if (chatClient != null &&
          channelJoinPayload.value != null &&
          channelJoinPayload.value!.active) {
        final payload = channelJoinPayload.value!;
        final job = AutoRetryJob<Channel>(
          () => chatClient.joinChannel(payload),
          jobName: 'Join Channel',
          alive: () => context.mounted && channelJoinPayload.value == payload,
        );
        job.run().then(
          (channel) {
            previous.value = channel;
          },
        ).onError((error, stackTrace) {
          if (error is JobExpired<Channel>) {
            // if job expired, leave the channel just joined
            error.result?.leave();
          }
        });
      }

      return previous;
    },
  ),

  ChangeNotifierProxyProvider<ChatChannel, ChatChannelData>(
    create: (context) => ChatChannelData(),
    update: (context, currentChannel, previous) {
      final channel = currentChannel.value;
      if (channel == null) {
        previous!.value = null;
        previous.unbind();
      } else {
        previous!.bind(channel.streams.data);
      }
      return previous;
    },
  ),
  ChangeNotifierProxyProvider<ChatChannel, ChatChannelLastMessage>(
    create: (context) => ChatChannelLastMessage(),
    update: (context, currentChannel, previous) {
      final channel = currentChannel.value;
      if (channel == null) {
        previous!.value = null;
        previous.unbind();
      } else {
        previous!.bind(channel.streams.message);
      }
      return previous;
    },
  ),
  ChangeNotifierProxyProvider<ChatChannel, ChatChannelFiles>(
    create: (context) => ChatChannelFiles(),
    update: (context, currentChannel, previous) {
      final channel = currentChannel.value;
      if (channel == null) {
        previous!.value = [];
        previous.unbind();
      } else {
        previous!.bind(channel.streams.file);
      }
      return previous;
    },
  ),
  ChangeNotifierProxyProvider<ChatChannel, ChatChannelWatchers>(
    create: (context) => ChatChannelWatchers(),
    update: (context, currentChannel, previous) {
      final channel = currentChannel.value;
      if (channel == null) {
        previous!.clear();
        previous.unbind();
      } else {
        previous!.bind(
          joinStream: channel.streams.joinEvents,
          leaveStream: channel.streams.leaver,
        );
      }
      return previous;
    },
  ),
]);
