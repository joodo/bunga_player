import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/screens/player_section/placeholder.dart';
import 'package:bunga_player/screens/player_section/popmoji_player.dart';
import 'package:flutter/material.dart';

class VideoSection extends StatefulWidget {
  final ValueNotifier<String?> hintTextNotifier;
  const VideoSection({super.key, required this.hintTextNotifier});

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
      onDoubleTap: FullScreen().toggle,
      onTap: VideoController().togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoController().video,
          ValueListenableBuilder<String?>(
            valueListenable: widget.hintTextNotifier,
            builder: (context, text, child) => text == null
                ? const SizedBox.shrink()
                : PlayerPlaceholder(
                    isAwakeNotifier: _loggedInNotifier,
                    textNotifier: widget.hintTextNotifier,
                  ),
          ),
          const PopmojiPlayer(),
        ],
      ),
    );
  }
}
