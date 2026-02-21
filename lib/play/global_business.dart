import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';

import 'history.dart';
import 'service/service.agora.dart';
import 'service/service.dart';
import 'service/service.media_kit.dart';

enum PlayerBackend { mediaKit, agoraMediaPlayer }

class PlayerBackendNotifier extends ValueNotifier<PlayerBackend> {
  PlayerBackendNotifier() : super(.mediaKit) {
    bindPreference<String>(
      key: 'player_backend',
      load: (pref) => PlayerBackend.values.byName(pref),
      update: (value) => value.name,
    );

    if (!getIt.isRegistered<MediaPlayer>()) _register(value);
  }

  Future<void> switchTo(PlayerBackend target) async {
    if (value == target) return;

    final current = getIt<MediaPlayer>();
    current.dispose();
    await getIt.unregister<MediaPlayer>();

    _register(target);
    value = target;
  }

  void _register(PlayerBackend target) {
    final instance = switch (target) {
      PlayerBackend.mediaKit => MediaKitMediaPlayer(),
      PlayerBackend.agoraMediaPlayer => AgoraMediaPlayer(),
    };
    getIt.registerSingleton<MediaPlayer>(instance);
  }
}

class PlayGlobalBusiness extends SingleChildStatefulWidget {
  const PlayGlobalBusiness({super.key, super.child});

  @override
  State<PlayGlobalBusiness> createState() => _PlayGlobalBusinessState();
}

class _PlayGlobalBusinessState extends SingleChildState<PlayGlobalBusiness> {
  // History
  final _history = History();

  @override
  void initState() {
    super.initState();

    _preventAudioDucking();

    // History
    _history.load();
    getIt<ExitCallbacks>().add(_history.save);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        Provider.value(value: _history),
        Provider.value(value: PlayerBackendNotifier()),
      ],
      child: child,
    );
  }

  void _preventAudioDucking() async {
    // TODO: useless?
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }
}
