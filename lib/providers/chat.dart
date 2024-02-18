import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/services/call.agora.dart';
import 'package:bunga_player/services/call.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/volume_notifier.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

// User
class CurrentUser extends ValueNotifier<User?> {
  CurrentUser() : super(null);
}

// Channel
class CurrentChannelId extends ValueNotifier<String?> {
  CurrentChannelId() : super(null);
}

class CurrentChannelData extends ValueNotifierWithOldValue<ChannelData?> {
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

  void set(Iterable<User> users) {
    _value.clear();
    _value.addAll(users);
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
    _value.removeWhere((u) => u.id == user.id);
    notifyListeners();
    for (final listener in _leaveListeners) {
      listener(user);
    }
  }
}

class CurrentChannelMessage extends ValueNotifier<Message?> {
  CurrentChannelMessage() : super(null);
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

class CallVolume extends VolumeNotifier {
  CallVolume() : super(getIt<Preferences>().get<int>('call_volume') ?? 50);
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

class CallNoiseSuppressionLevel extends ValueNotifier<NoiseSuppressionLevel> {
  CallNoiseSuppressionLevel() : super(NoiseSuppressionLevel.high) {
    addListener(() {
      (getIt<CallService>() as Agora).setNoiseSuppression(value);
    });
  }
}

final chatProviders = MultiProvider(providers: [
  // User
  ChangeNotifierProvider(create: (context) => CurrentUser()),

  // Channel
  ChangeNotifierProvider(create: (context) => CurrentChannelId()),
  ChangeNotifierProvider(create: (context) => CurrentChannelData()),
  ChangeNotifierProvider(create: (context) => CurrentChannelWatchers()),
  ChangeNotifierProvider(create: (context) => CurrentChannelMessage()),

  // Voice call
  ChangeNotifierProvider(create: (context) => CurrentCallStatus()),
  ChangeNotifierProvider(create: (context) => CurrentTalkersCount()),
  ChangeNotifierProvider(create: (context) => CallVolume()),
  ChangeNotifierProvider(create: (context) => MuteMic()),
  ChangeNotifierProvider(create: (context) => CallNoiseSuppressionLevel()),
]);
