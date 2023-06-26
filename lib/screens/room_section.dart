import 'package:bunga_player/common/video_open.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/singletons/im_video_connector.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/singletons/snack_bar.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class RoomSection extends StatefulWidget {
  const RoomSection({super.key});

  @override
  State<RoomSection> createState() => _RoomSectionState();
}

class _RoomSectionState extends State<RoomSection> {
  bool _isUnsyncNotificationShow = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),

        // Watcher list
        ListenableBuilder(
          listenable: IMController().channelWatchers,
          builder: (context, child) {
            if (IMController().currentUserNotifier.value == null) {
              return const SizedBox.shrink();
            }

            String text = IMController()
                .channelWatchers
                .toStringExcept(IMController().currentUserNotifier.value!);
            if (text.isEmpty) {
              return const SizedBox.shrink();
            }

            return Text(
              '$text 在和你一起看',
              textAlign: TextAlign.left,
            );
          },
        ),
        const Spacer(),

        // Unsync hint
        MultiValueListenableBuilder(
          valueListenables: [
            VideoController().videoHashNotifier,
            IMController().channelUpdateEventNotifier,
          ],
          builder: (context, values, child) {
            final roomUpdateEvent = values[1] as Event?;
            if (roomUpdateEvent == null || // When init
                IMController().currentChannel == null || // After leave room
                UINotifiers().isBusy.value == true || // loading video
                IMVideoConnector().isVideoSameWithRoom) {
              return const SizedBox.shrink();
            }

            return PortalTarget(
              visible: _isUnsyncNotificationShow,
              portalFollower: GestureDetector(
                onTap: () {
                  setState(() {
                    _isUnsyncNotificationShow = false;
                  });
                },
              ),
              child: PortalTarget(
                visible: _isUnsyncNotificationShow,
                anchor: const Aligned(
                  follower: Alignment.topRight,
                  target: Alignment.bottomRight,
                ),
                portalFollower: Card(
                  elevation: 8,
                  child: SizedBox(
                    width: 260,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '你和 ${roomUpdateEvent.user?.name ?? "对方"} 正在播放不同的视频。'),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: '对方正在播放 ',
                              children: <TextSpan>[
                                TextSpan(
                                  text: roomUpdateEvent.channel
                                          ?.extraData['name'] as String? ??
                                      '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _onOpenVideoPressed(
                                  roomUpdateEvent.channel?.extraData['hash']
                                      as String),
                              child: const Text('打开对应的视频'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _isUnsyncNotificationShow = true;
                  }),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: const Icon(
                    Icons.warning,
                    size: 16,
                  ),
                  label: const Text('播放不同步'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _onOpenVideoPressed(String videoHash) {
    setState(() {
      _isUnsyncNotificationShow = false;
    });

    return videoHash.split('-').first == 'local'
        ? _openLocalVideo()
        : IMVideoConnector().followRemoteBiliVideoHash(videoHash);
  }

  void _openLocalVideo() async {
    UINotifiers().isBusy.value = true;
    try {
      await openLocalVideo();
      IMVideoConnector().askPosition();
    } catch (e) {
      if (e is! NoFileSelectedException) {
        logger.e(e);
        showSnackBar('加载失败');
      }
    } finally {
      UINotifiers().hintText.value = null;
      UINotifiers().isBusy.value = false;
    }
  }
}
