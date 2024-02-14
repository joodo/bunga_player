import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/chat/message.dart';
import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
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
  CurrentCallStatus(super.value);
}

class CurrentTalkersCount extends ValueNotifier<int> {
  CurrentTalkersCount() : super(0);
}

class CallVolume extends ChangeNotifier {
  static const int maxVolume = 100;
  static const int minVolume = 0;

  CallVolume();

  int _volume = _pref<int>('call_volume', 50);
  int get volume => _volume;
  set volume(int newVolume) {
    _volume = newVolume.clamp(minVolume, maxVolume);
    notifyListeners();
  }

  bool _isMute = false;
  bool get isMute => _isMute;
  set isMute(bool mute) {
    _isMute = mute;
    notifyListeners();
  }

  double get percent => volume / (maxVolume - minVolume);
}

class CallMute extends ValueNotifier<bool> {
  CallMute(super.value);
}

T _pref<T>(String key, T defaultValue) =>
    getIt<Preferences>().get<T>(key) ?? defaultValue;

final providers = MultiProvider(providers: [
  // User
  ChangeNotifierProvider(create: (context) => CurrentUser()),

  // Channel
  ChangeNotifierProvider(create: (context) => CurrentChannelId()),
  ChangeNotifierProvider(create: (context) => CurrentChannelData()),
  ChangeNotifierProvider(create: (context) => CurrentChannelWatchers()),
  ChangeNotifierProvider(create: (context) => CurrentChannelMessage()),

  // Voice call
  ChangeNotifierProvider(
      create: (context) => CurrentCallStatus(CallStatus.none)),
  ChangeNotifierProvider(create: (context) => CurrentTalkersCount()),
  ChangeNotifierProvider(create: (context) => CallVolume()),
]);
