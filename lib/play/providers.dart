import 'dart:convert';

import 'package:async/async.dart';
import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/play/models/video_session.dart';
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

class PlayAudioTracksNotifier extends ValueNotifier<Iterable<AudioTrack>> {
  PlayAudioTracksNotifier() : super([]);
}

class PlayAudioTrackIDNotifier extends ValueNotifier<String> {
  PlayAudioTrackIDNotifier() : super('');
}

class PlaySubtitleTracks extends ValueNotifier<Iterable<SubtitleTrack>> {
  PlaySubtitleTracks() : super([]);
}

class PlaySubtitleTrackID extends ValueNotifier<String> {
  PlaySubtitleTrackID() : super('');
}

enum PlayStatusType { play, pause, stop }

class PlayVolume extends ValueNotifier<Volume> {
  PlayVolume()
      : super(Volume(
          volume: getIt<Preferences>().getOrCreate('play_volume', Volume.max),
        ));

  void save(int volume) {
    value = Volume(volume: volume);
    getIt<Preferences>().set('play_volume', volume);
  }
}

class PlayRate extends ValueNotifierWithReset<double> {
  PlayRate() : super(1.0);
}

typedef BCSGHPreset = ({
  String title,
  List<int> value,
});

class PlayEqPresetNotifier extends ValueNotifier<BCSGHPreset?> {
  static final presets = <BCSGHPreset>[
    (title: '默认', value: [0, 0, 0, 0, 0]),
    (title: '鲜艳与生动', value: [5, 20, 65, 10, 0]),
    (title: '电影感', value: [-5, 30, 10, -5, 0]),
    (title: '温暖与复古', value: [10, 15, 10, 5, 5]),
    (title: '凉爽与情绪化', value: [-5, 20, -10, -10, -5]),
    (title: '夜视模式', value: [30, 40, -30, 20, 90]),
    (title: '黑白经典', value: [0, 15, -100, 0, 0]),
    (title: '褐色调', value: [5, 10, -20, 0, 30]),
    (title: '高调', value: [20, -15, 10, 10, 0]),
    (title: '低调', value: [-20, 25, -10, -10, 0]),
    (title: '漂白偏移', value: [0, 30, -50, 0, 0]),
  ];
  PlayEqPresetNotifier() : super(presets.first);
}

class PlaySubDelay extends ValueNotifier<double> {
  PlaySubDelay() : super(0);
}

class PlaySubSize extends ValueNotifier<int> {
  PlaySubSize() : super(0);
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
    getIt<ExitCallbacks>().add(save);
  }

  void dispose() {
    getIt<ExitCallbacks>().remove(save);
  }

  Future<void> _load() async {
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

  Future<void> save() {
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
    ChangeNotifierProvider(create: (context) => PlayDuration()),
    ChangeNotifierProvider(create: (context) => PlayPosition()),
    ChangeNotifierProvider(create: (context) => PlaySavedPosition()),
    Provider(create: (context) => PlayVideoSessions(context.read)),
    ChangeNotifierProvider(create: (context) => PlayBuffer()),
    ChangeNotifierProvider(create: (context) => PlayIsBuffering(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlayAudioTracksNotifier(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlayAudioTrackIDNotifier(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlaySubtitleTracks(), lazy: false),
    ChangeNotifierProvider(
        create: (context) => PlaySubtitleTrackID(), lazy: false),
    ChangeNotifierProvider(create: (context) => PlayVolume()),
    ChangeNotifierProvider(create: (context) => PlayRate()),
    ChangeNotifierProvider(create: (context) => PlayEqPresetNotifier()),
    ChangeNotifierProvider(create: (context) => PlaySubDelay()),
    ChangeNotifierProvider(create: (context) => PlaySubPos()),
    ChangeNotifierProvider(create: (context) => PlaySubSize()),
  ],
);
