import 'dart:async';

import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/clients/chat.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/utils/auto_retry.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'clients/bunga.dart';

// User
class CurrentUser extends ValueNotifier<OwnUser?> {
  CurrentUser() : super(null);
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

class CurrentChannelJoinPayload extends ValueNotifier<ChannelJoinPayload?> {
  CurrentChannelJoinPayload() : super(null);
}

class CurrentChannel extends ValueNotifier<Channel?> with StreamBinding {
  CurrentChannel() : super(null);
}

class CurrentChannelData extends ValueNotifier<ChannelData?>
    with StreamBinding {
  CurrentChannelData() : super(null);
}

typedef WatchersChangedEventListener = void Function(User uesr);

class CurrentChannelWatchers extends ChangeNotifier
    implements ValueListenable<List<User>> {
  final List<User> _value = [];
  @override
  List<User> get value => _value;
  void clear() {
    _value.clear();
    notifyListeners();
  }

  // Join
  final List<WatchersChangedEventListener> _joinListeners = [];
  void addJoinListener(WatchersChangedEventListener listener) {
    _joinListeners.add(listener);
  }

  void removeJoinListener(WatchersChangedEventListener listener) {
    _joinListeners.remove(listener);
  }

  void join(User user) {
    if (_value.containsId(user.id)) return;
    _value.add(user);
    notifyListeners();
    for (final listener in _joinListeners) {
      listener(user);
    }
  }

  // Remove
  final List<WatchersChangedEventListener> _leaveListeners = [];
  void addLeaveListener(WatchersChangedEventListener listener) {
    _leaveListeners.add(listener);
  }

  void removeLeaveListener(WatchersChangedEventListener listener) {
    _leaveListeners.remove(listener);
  }

  void leave(User user) {
    _value.removeId(user.id);
    notifyListeners();
    for (final listener in _leaveListeners) {
      listener(user);
    }
  }

  final _subscriptions = <StreamSubscription>[];
  bool get isBinded => _subscriptions.isNotEmpty;

  void bind(Stream<User> joinStream, Stream<User> leaveStream) {
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

class CurrentChannelMessage extends ValueNotifier<Message?> with StreamBinding {
  CurrentChannelMessage() : super(null);
}

class CurrentChannelFiles extends ValueNotifier<Iterable<ChannelFile>> {
  CurrentChannelFiles() : super([]);

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

// Voice call
enum CallStatus {
  none,
  callIn,
  callOut,
  talking,
}

class CurrentCallStatus extends ValueNotifier<CallStatus> {
  CurrentCallStatus() : super(CallStatus.none);
}

class CurrentTalkersCount extends ValueNotifier<int> {
  CurrentTalkersCount() : super(0);
}

class MuteMic extends ValueNotifier<bool> {
  MuteMic() : super(false);
}

enum NoiseSuppressionLevel {
  none,
  low,
  middle,
  high,
}

class Danmaku {
  final User sender;
  final String text;

  Danmaku({required this.sender, required this.text});
}

class LastDanmaku extends ValueNotifier<Danmaku?> {
  LastDanmaku() : super(null);
}

final chatProviders = MultiProvider(providers: [
  // User
  ChangeNotifierProxyProvider3<ChatClient?, SettingUserName, SettingColorHue,
      CurrentUser>(
    create: (context) => CurrentUser(),
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
            context.read<SettingClientId>().value,
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
  ChangeNotifierProvider(create: (context) => CurrentChannelJoinPayload()),
  ChangeNotifierProxyProvider2<ChatClient?, CurrentChannelJoinPayload,
      CurrentChannel>(
    create: (context) => CurrentChannel(),
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

  ChangeNotifierProxyProvider<CurrentChannel, CurrentChannelData>(
    create: (context) => CurrentChannelData(),
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
  ChangeNotifierProxyProvider<CurrentChannel, CurrentChannelMessage>(
    create: (context) => CurrentChannelMessage(),
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
  ChangeNotifierProxyProvider<CurrentChannel, CurrentChannelFiles>(
    create: (context) => CurrentChannelFiles(),
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
  ChangeNotifierProxyProvider<CurrentChannel, CurrentChannelWatchers>(
    create: (context) => CurrentChannelWatchers(),
    update: (context, currentChannel, previous) {
      final channel = currentChannel.value;
      if (channel == null) {
        previous!.clear();
        previous.unbind();
      } else {
        previous!.bind(channel.streams.joiner, channel.streams.leaver);
      }
      return previous;
    },
  ),

  // Voice call
  ChangeNotifierProvider(create: (context) => CurrentCallStatus()),
  ChangeNotifierProvider(create: (context) => CurrentTalkersCount()),
  ChangeNotifierProvider(create: (context) => MuteMic()),

  // Danmaku
  ChangeNotifierProvider(create: (context) => LastDanmaku()),
]);
