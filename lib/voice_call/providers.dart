import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/chat/providers.dart';
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

class VoiceCallTalkers extends ValueNotifier<List<String>?> {
  VoiceCallTalkers() : super(null);

  void add(String id) {
    assert(value != null);
    if (!value!.contains(id)) value = [...value!, id];
  }

  void remove(String id) {
    assert(value != null);
    if (value!.contains(id)) value = [...value!..remove(id)];
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
  ChangeNotifierProvider(create: (context) => VoiceCallStatus()),
]);
