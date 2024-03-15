import 'package:bunga_player/models/playing/volume.dart';
import 'package:bunga_player/models/playing/watch_progress.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class PlayDuration extends ValueNotifier<Duration> {
  PlayDuration() : super(Duration.zero);
}

class PlayBuffer extends ValueNotifier<Duration> {
  PlayBuffer() : super(Duration.zero);
}

class PlayIsBuffering extends ValueNotifier<bool> {
  PlayIsBuffering() : super(false);
}

class PlayPosition extends ValueNotifier<Duration> {
  PlayPosition() : super(Duration.zero);
}

class PlayAudioTracks extends ValueNotifier<Iterable<AudioTrack>> {
  PlayAudioTracks() : super([]);
}

class PlayAudioTrackID extends ValueNotifier<String> {
  PlayAudioTrackID() : super('');
}

class PlaySubtitleTracks extends ValueNotifier<Iterable<SubtitleTrack>> {
  PlaySubtitleTracks() : super([]);
}

class PlaySubtitleTrackID extends ValueNotifier<String> {
  PlaySubtitleTrackID() : super('');
}

enum PlayStatusType { play, pause, stop }

class PlayStatus extends ValueNotifier<PlayStatusType> {
  PlayStatus() : super(PlayStatusType.stop);
  bool get isPlaying => value == PlayStatusType.play;
}

class PlayVolume extends ValueNotifier<Volume> {
  PlayVolume()
      : super(
          Volume(
            volume: getIt<Preferences>().get<int>('play_volume') ?? Volume.max,
          ),
        ) {
    addListener(() {
      getIt<Preferences>().set('play_volume', value.volume);
    });
  }
}

class PlayContrast extends ValueNotifier<int> {
  PlayContrast() : super(0);
}

class PlaySubDelay extends ValueNotifier<double> {
  PlaySubDelay() : super(0);
}

class PlaySubSize extends ValueNotifier<int> {
  PlaySubSize() : super(Player.defaultSubSize);
}

class PlaySubPos extends ValueNotifier<int> {
  PlaySubPos() : super(0);
}

class PlayVideoEntry extends ValueNotifier<VideoEntry?> {
  PlayVideoEntry() : super(null);
}

class PlaySourceIndex extends ValueNotifier<int?> {
  PlaySourceIndex() : super(null);
}

class PlayWatchProgresses {
  late final Map<String, WatchProgress> value;
  WatchProgress? get(String videoHash) => value[videoHash];
}

final playerProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => PlayVideoEntry(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlaySourceIndex(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayStatus(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayDuration()),
    ChangeNotifierProvider(create: (context) => PlayBuffer()),
    ChangeNotifierProvider(create: (context) => PlayIsBuffering(), lazy: false),
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
