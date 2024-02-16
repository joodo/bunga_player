import 'package:flutter/foundation.dart';

class VolumeNotifier extends ChangeNotifier {
  static const int maxVolume = 100;
  static const int minVolume = 0;

  VolumeNotifier(int volume) : _volume = volume.clamp(minVolume, maxVolume);

  int _volume;
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
