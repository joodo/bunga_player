import 'package:bunga_player/actions/auth.dart';
import 'package:bunga_player/actions/channel.dart';
import 'package:bunga_player/actions/danmaku.dart';
import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/actions/ui.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/actions/voice_call.dart';
import 'package:nested/nested.dart';

class ActionsWrapper extends Nested {
  ActionsWrapper({super.key, super.child})
      : super(children: [
          const UIActions(),
          const PlayActions(),
          const AuthActions(),
          const VideoPlayingActions(),
          const ChannelActions(),
          const VoiceCallActions(),
          const DanmakuActions(),
        ]);
}
