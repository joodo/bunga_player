import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play/service/service.media_kit.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'history.dart';

class PlayGlobalBusiness extends SingleChildStatefulWidget {
  const PlayGlobalBusiness({super.key, super.child});

  @override
  State<PlayGlobalBusiness> createState() => _PlayGlobalBusinessState();
}

class NetworkCacheSizeNotifier extends ValueNotifier<int> {
  NetworkCacheSizeNotifier() : super(500) {
    bindPreference<int>(
      key: 'network_cache_size',
      load: (pref) => pref,
      update: (value) => value,
    );

    _applyCacheSize();
    addListener(_applyCacheSize);
  }

  void _applyCacheSize() {
    // TODO: only for MediaKitPlayService
    //(getIt<PlayService>() as MediaKitPlayService).setCacheSize(value);
  }
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
        ChangeNotifierProvider(
          create: (context) => NetworkCacheSizeNotifier(),
          lazy: false,
        ),
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
