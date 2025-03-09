import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'models/history.dart';

class PlayActions extends SingleChildStatefulWidget {
  const PlayActions({super.key, super.child});

  @override
  State<PlayActions> createState() => _PlayActionsState();
}

class _PlayActionsState extends SingleChildState<PlayActions> {
  // History
  late final History _history;

  @override
  void initState() {
    super.initState();

    _preventAudioDucking();

    // History
    _history = History.load();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        Provider.value(value: _history),
      ],
      child: child,
    );
  }

  void _preventAudioDucking() async {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) return;

    final session = await AudioSession.instance;
    // TODO:: check if this is necessary
    await session.configure(const AudioSessionConfiguration.speech());
  }
}
