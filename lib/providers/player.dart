import 'dart:async';
import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/models/playing/watch_progress.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class StreamValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  StreamValueNotifier(Stream<T> stream, T defultValue) : _value = defultValue {
    _subscription = stream.listen((value) {
      if (_value == value) return;
      _value = value;
      notifyListeners();
    });

    if (defultValue != null) _value = defultValue;
  }

  T _value;
  @override
  T get value => _value;

  late final StreamSubscription _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _getPlayer = getIt.call<Player>;

class PlayDuration extends StreamValueNotifier<Duration> {
  PlayDuration() : super(_getPlayer().durationStream, Duration.zero);
}

class PlayBuffer extends StreamValueNotifier<Duration> {
  PlayBuffer() : super(_getPlayer().bufferStream, Duration.zero);
}

class PlayPosition extends ChangeNotifier implements ValueListenable<Duration> {
  PlayPosition() {
    _subscription = _getPlayer().positionStream.listen((position) {
      // When dragging progress bar, do not sync stream data
      if (!stopListenStream) _value = position;
    });
  }

  late final StreamSubscription _subscription;

  bool stopListenStream = false;

  void seekTo(Duration newPosition) {
    assert(stopListenStream);
    _value = newPosition;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Duration __value = Duration.zero;
  @override
  Duration get value => __value;
  set _value(Duration p) {
    if (p == __value) return;
    __value = p;
    notifyListeners();
  }
}

class PlayAudioTracks extends StreamValueNotifier<Iterable<AudioTrack>> {
  PlayAudioTracks() : super(_getPlayer().audioTracksStream, []);
}

class PlayAudioTrackID extends StreamValueNotifier<String> {
  PlayAudioTrackID() : super(_getPlayer().currentAudioTrackID, '');

  set value(String newId) {
    if (_value == newId) return;
    _getPlayer().setAudioTrackID(newId);

    _value = newId;
    notifyListeners();
  }
}

class PlaySubtitleTracks extends StreamValueNotifier<Iterable<SubtitleTrack>> {
  PlaySubtitleTracks() : super(_getPlayer().subtitleTracksStream, []);
}

class PlaySubtitleTrackID extends StreamValueNotifier<String> {
  PlaySubtitleTrackID() : super(_getPlayer().currentSubtitleTrackID, '');
}

enum PlayStatusType { play, pause, stop }

class PlayStatus extends StreamValueNotifier<PlayStatusType> {
  PlayStatus() : super(_getPlayer().statusStream, PlayStatusType.stop);

  bool get isPlaying => value == PlayStatusType.play;
}

class PlayVolume extends StreamValueNotifier<Volume> {
  PlayVolume()
      : super(
          _getPlayer().volumeStream,
          Volume(volume: 100, mute: false),
        ) {
    final savedVolume = getIt<Preferences>().get<int>('play_volume');
    if (savedVolume != null) _getPlayer().setVolume(savedVolume);

    addListener(() {
      getIt<Preferences>().set('play_volume', volume);
    });
  }
  int get volume => value.volume;
  bool get mute => value.mute;
}

class PlayContrast extends StreamValueNotifier<int> {
  PlayContrast() : super(_getPlayer().contrastStream, 0);
}

class PlaySubDelay extends StreamValueNotifier<double> {
  PlaySubDelay() : super(_getPlayer().subDelayStream, 0);
}

class PlaySubSize extends StreamValueNotifier<int> {
  PlaySubSize() : super(_getPlayer().subSizeStream, Player.defaultSubSize);
}

class PlaySubPos extends StreamValueNotifier<int> {
  PlaySubPos() : super(_getPlayer().subPosStream, 0);
}

class PlayVideoEntry extends StreamValueNotifier<VideoEntry?> {
  PlayVideoEntry() : super(_getPlayer().videoEntryStream, null);
}

class PlaySourceIndex extends StreamValueNotifier<int?> {
  PlaySourceIndex() : super(_getPlayer().sourceIndexStream, null);
}

class PlayWatchProgresses {
  final value = getIt<Player>().watchProgresses;
  WatchProgress? get(String videoHash) => value[videoHash];
}

final playerProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => PlayVideoEntry(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlaySourceIndex(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayStatus(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayDuration()),
    ChangeNotifierProvider(create: (context) => PlayBuffer()),
    ChangeNotifierProvider(create: (context) => PlayPosition()),
    ChangeNotifierProvider(create: (context) => PlayAudioTracks(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlayAudioTrackID(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlaySubtitleTracks(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlaySubtitleTrackID(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayVolume()),
    ChangeNotifierProvider(create: (context) => PlayContrast()),
    ChangeNotifierProvider(create: (context) => PlaySubDelay()),
    ChangeNotifierProvider(create: (context) => PlaySubPos()),
    ChangeNotifierProvider(create: (context) => PlaySubSize()),
    Provider(create: (context) => PlayWatchProgresses()),
  ],
);
