import 'package:audioplayers/audioplayers.dart';

class BungaAudioPlayer {
  final _ringPlayer = AudioPlayer()
    ..setSource(AssetSource('sounds/call.mp3'))
    ..setReleaseMode(ReleaseMode.loop);
  final _sfxPlayer = AudioPlayer(playerId: 'short_sfx');

  BungaAudioPlayer() {
    _ringPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gainTransient,
      ),
    ));
    _sfxPlayer.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.assistanceSonification,
        audioFocus: AndroidAudioFocus.none,
      ),
    ));
  }

  void startRing() {
    _ringPlayer.resume();
  }

  void stopRing() {
    _ringPlayer.stop();
  }

  void playSfx(String sfxName) {
    _sfxPlayer.play(
      AssetSource('sounds/$sfxName.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }
}
