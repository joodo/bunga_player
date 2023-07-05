import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;

class PlayerSection extends StatefulWidget {
  const PlayerSection({super.key});

  @override
  State<PlayerSection> createState() => _PlayerSectionState();
}

class _PlayerSectionState extends State<PlayerSection> {
  final _isLoginedNotifier =
      Chat().currentUserNameNotifier.map<bool>((name) => name != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => Actions.maybeInvoke(
          context, SetFullScreenIntent(!UINotifiers().isFullScreen.value)),
      onTap: () => Actions.maybeInvoke(context, const TogglePlayIntent()),
      child: Stack(
        fit: StackFit.expand,
        children: [
          media_kit.Video(controller: VideoPlayer().controller),
          ValueListenableBuilder<String?>(
            valueListenable: UINotifiers().hintText,
            builder: (context, text, child) => AnimatedOpacity(
              opacity: text == null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: PlayerPlaceholder(isAwakeNotifier: _isLoginedNotifier),
            ),
          ),
          const PopmojiPlayer(),
        ],
      ),
    );
  }
}
