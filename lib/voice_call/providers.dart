import 'dart:async';

import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'client/client.dart';

enum VoiceCallStatusType {
  none,
  callIn,
  callOut,
  talking,
}

class VoiceCallStatus extends ValueNotifier<VoiceCallStatusType> {
  VoiceCallStatus() : super(VoiceCallStatusType.none);
}

class VoiceCallTalkers extends ValueNotifier<List<int>> {
  VoiceCallTalkers() : super([]);

  void clear() {
    value = [];
  }

  final _subscriptions = <StreamSubscription>[];
  bool get isBinded => _subscriptions.isNotEmpty;

  void bind({
    required Stream<int> joinStream,
    required Stream<int> leaveStream,
  }) {
    assert(!isBinded);
    _subscriptions.addAll([
      joinStream.listen((joinerId) {
        if (!value.contains(joinerId)) value = [...value, joinerId];
      }),
      leaveStream.listen((leaverId) {
        if (value.remove(leaverId)) value = [...value];
      }),
    ]);
  }

  Future<void> unbind() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}

class VoiceCallMuteMic extends ValueNotifier<bool> {
  VoiceCallMuteMic() : super(false);
}

enum NoiseSuppressionLevel {
  none,
  low,
  middle,
  high,
}

class VoiceCallVolume extends ValueNotifier<Volume> {
  VoiceCallVolume() : super(Volume(volume: (Volume.max - Volume.min) ~/ 2)) {
    bindPreference<int>(
      preferences: getIt<Preferences>(),
      key: 'call_volume',
      load: (pref) => Volume(volume: pref),
      update: (value) => value.volume,
    );
  }
}

class VoiceCallNoiseSuppressionLevel
    extends ValueNotifier<NoiseSuppressionLevel> {
  VoiceCallNoiseSuppressionLevel() : super(NoiseSuppressionLevel.high);
}

final voiceCallProviders = MultiProvider(providers: [
  ChangeNotifierProvider(create: (context) => VoiceCallVolume()),
  ChangeNotifierProvider(create: (context) => VoiceCallMuteMic()),
  ChangeNotifierProvider(create: (context) => VoiceCallNoiseSuppressionLevel()),
  ProxyProvider<BungaClient?, VoiceCallClient?>(
    update: (context, bungaClient, previous) => bungaClient == null
        ? null
        : AgoraClient(
            bungaClient,
            volume: context.read<VoiceCallVolume>().value.percent,
            noiseSuppressionLevel:
                context.read<VoiceCallNoiseSuppressionLevel>().value,
          ),
    lazy: false,
  ),
  ChangeNotifierProxyProvider<VoiceCallClient?, VoiceCallTalkers>(
    create: (context) => VoiceCallTalkers(),
    update: (context, client, previous) {
      previous!.unbind().then((_) {
        if (client != null) {
          previous.bind(
            joinStream: client.joinerStream,
            leaveStream: client.leaverStream,
          );
        }
      });
      return previous;
    },
    lazy: false,
  ),
  ChangeNotifierProvider(create: (context) => VoiceCallStatus()),
]);
