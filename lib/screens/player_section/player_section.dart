import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_controller.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:flutter/material.dart';

class VideoSection extends StatefulWidget {
  const VideoSection({super.key});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  final _loggedInNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    IMController().currentUserNotifier.addListener(() {
      _loggedInNotifier.value =
          IMController().currentUserNotifier.value != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () =>
          UINotifiers().isFullScreen.value = !UINotifiers().isFullScreen.value,
      onTap: VideoController().togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoController().video,
          ValueListenableBuilder<String?>(
            valueListenable: UINotifiers().hintText,
            builder: (context, text, child) => AnimatedOpacity(
              opacity: text == null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: PlayerPlaceholder(
                isAwakeNotifier: _loggedInNotifier,
              ),
            ),
          ),
          const PopmojiPlayer(),
        ],
      ),
    );
  }
}
