import 'dart:convert';

import 'package:async/async.dart';
import 'package:bunga_player/player/models/video_session.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/extensions/duration.dart';
import 'package:bunga_player/utils/extensions/string.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'models/video_entries/video_entry.dart';
import 'service/service.dart';

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
  PlayVolume() : super(Volume(volume: Volume.max)) {
    bindPreference<int>(
      preferences: getIt<Preferences>(),
      key: 'play_volume',
      load: (pref) => Volume(volume: pref),
      update: (value) => value.volume,
    );
  }
}

class PlayRate extends ValueNotifierWithReset<double> {
  PlayRate() : super(1.0);
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

class PlaySavedPosition extends ValueNotifier<Duration?> {
  PlaySavedPosition() : super(null);
}

class PlayVideoSessions {
  final Map<String, VideoSession> _data = {};
  final Locator read;

  PlayVideoSessions(this.read) {
    _load().then((_) {
      _cleanOld();
    });

    // Register save progress when quit
    getIt<ExitCallbacks>().add(_save);
  }

  void dispose() {
    getIt<ExitCallbacks>().remove(_save);
  }

  Future<void> _load() async {
    if (await _upgrade()) return;

    final compressed = getIt<Preferences>().get<String>('video_sessions');

    try {
      final rawData = compressed?.decompress();
      final sessionJsons = jsonDecode(rawData!) as List;

      for (var json in sessionJsons) {
        final session = VideoSession.fromJson(json);
        _data[session.hash] = session;
      }
    } catch (e) {
      logger.w('Load video session failed');
    }
  }

  void _cleanOld() {
    if (_data.length < 100) return;

    final sorted = _data.values.toList();
    sorted.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    sorted.removeRange(0, 100);

    for (var session in sorted) {
      _data.remove(session.hash);
    }
  }

  @Deprecated('For upgrade data, remove it next version')
  Future<bool> _upgrade() async {
    final rawData = getIt<Preferences>().get<String>('watch_progress');
    if (rawData == null) return false;

    try {
      final o = jsonDecode(rawData);
      final d = Map.castFrom(o);
      for (var entry in d.entries) {
        _data[entry.key] = VideoSession(
          entry.key,
          progress: WatchProgress.fromJson(entry.value),
        );
      }

      await _save();
      await getIt<Preferences>().remove('watch_progress');
    } catch (e) {
      logger.w('Load watch progress failed');
      return false;
    }

    return true;
  }

  Future<void> _save() {
    final rawData = jsonEncode(_data.values.toList());
    final compressed = rawData.compress();
    return getIt<Preferences>().set('video_sessions', compressed);
  }

  // Session
  VideoSession? get(String hash) => _data[hash];
  VideoSession? get current {
    final hash = read<PlayVideoEntry>().value?.hash;
    return _data[hash];
  }

  VideoSession currentOrCreate() {
    final hash = read<PlayVideoEntry>().value!.hash;
    if (!_data.containsKey(hash)) _data[hash] = VideoSession(hash);
    return _data[hash]!;
  }

  void clearAll() => _data.clear();
  int get count => _data.length;

  // Watch progress
  late final RestartableTimer _saveWatchProgressTimer = RestartableTimer(
    const Duration(seconds: 3),
    () {
      _saveCurrentProgress();
      _saveWatchProgressTimer.reset();
    },
  );
  void startRecordingProgress() => _saveWatchProgressTimer.reset();
  void stopRecordingProgress() => _saveWatchProgressTimer.cancel();

  void _saveCurrentProgress() {
    final position = read<PlayPosition>().value;
    final duration = read<PlayDuration>().value;
    final progress = WatchProgress(
      position: position.inMilliseconds,
      duration: duration.inMilliseconds,
    );

    currentOrCreate().progress = progress;
  }
}

final playerProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => PlayVideoEntry(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlaySourceIndex(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayStatus(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayDuration()),
    ChangeNotifierProvider(create: (context) => PlayPosition()),
    ChangeNotifierProxyProvider2<PlayStatus, PlayPosition, PlaySavedPosition>(
      create: (context) => PlaySavedPosition(),
      update: (context, status, position, previous) {
        if (previous!.value != null &&
            position.value.near(previous.value!) &&
            status.value == PlayStatusType.play) previous.value = null;

        return previous;
      },
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => PlayBuffer()),
    ChangeNotifierProvider(create: (context) => PlayIsBuffering(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayAudioTracks(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlayAudioTrackID(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlaySubtitleTracks(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlaySubtitleTrackID(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayVolume()),
    ChangeNotifierProvider(create: (context) => PlayRate()),
    ChangeNotifierProvider(create: (context) => PlayContrast()),
    ChangeNotifierProvider(create: (context) => PlaySubDelay()),
    ChangeNotifierProvider(create: (context) => PlaySubPos()),
    ChangeNotifierProvider(create: (context) => PlaySubSize()),
    ProxyProvider<PlayStatus, PlayVideoSessions>(
      create: (context) => PlayVideoSessions(context.read),
      update: (context, statusNotifier, previous) {
        statusNotifier.isPlaying
            ? previous!.startRecordingProgress()
            : previous!.stopRecordingProgress();
        return previous;
      },
      dispose: (context, value) => value.dispose(),
      lazy: false,
    ),
  ],
);
