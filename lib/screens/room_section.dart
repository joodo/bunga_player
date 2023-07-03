import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/controllers/player_controller.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/utils/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class RoomSection extends StatefulWidget {
  const RoomSection({super.key});

  @override
  State<RoomSection> createState() => _RoomSectionState();
}

class _RoomSectionState extends State<RoomSection> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),

        // Watcher list
        ValueListenableBuilder(
          valueListenable: Chat().watchersNotifier,
          builder: (context, value, child) {
            if (Chat().currentUserNotifier.value == null) {
              return const SizedBox.shrink();
            }

            String text = _getUsersString(
              userList: Chat().watchersNotifier.value,
              except: Chat().currentUserNotifier.value,
            );
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
        StreamBuilder<Event?>(
          stream: Chat().channelUpdateEventStream,
          initialData: null,
          builder: (context, eventSnapshot) => ValueListenableBuilder(
            valueListenable: VideoPlayer().videoHashNotifier,
            builder: (context, value, child) {
              final channelData = Chat().channelExtraDataNotifier.value;
              if (UINotifiers().isBusy.value == true || // loading video
                  VideoPlayer().isStoppedNotifier.value || // stopped
                  channelData['hash'] ==
                      VideoPlayer().videoHashNotifier.value) {
                return const SizedBox.shrink();
              }

              return _VideoUnsyncNotification(
                onAction: () =>
                    _onOpenVideoPressed(channelData['hash'] as String),
                otherUserName: eventSnapshot.data?.user?.name ?? "对方",
                otherVideoTitle: channelData['name'] as String? ?? '',
              );
            },
          ),
        ),
      ],
    );
  }

  void _onOpenVideoPressed(String videoHash) {
    return videoHash.split('-').first == 'local'
        ? _openLocalVideo()
        : PlayerController().followRemoteBiliVideoHash(videoHash);
  }

  void _openLocalVideo() async {
    UINotifiers().isBusy.value = true;
    try {
      await openLocalVideo();
      PlayerController().askPosition();
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

  String _getUsersString(
      {required List<User>? userList, required User? except}) {
    if (userList == null || except == null) return '';

    String result = '';
    for (var user in userList) {
      if (user.id == except.id) continue;
      result += '${user.name}, ';
    }

    try {
      result = result.substring(0, result.length - 2);
    } catch (e) {
      return '';
    }

    return result;
  }
}

class _VideoUnsyncNotification extends StatefulWidget {
  final VoidCallback onAction;
  final String otherUserName;
  final String otherVideoTitle;

  const _VideoUnsyncNotification({
    required this.onAction,
    required this.otherUserName,
    required this.otherVideoTitle,
  });

  @override
  State<_VideoUnsyncNotification> createState() =>
      _VideoUnsyncNotificationState();
}

class _VideoUnsyncNotificationState extends State<_VideoUnsyncNotification> {
  bool _isUnsyncNotificationShow = false;

  @override
  Widget build(BuildContext context) => PortalTarget(
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
                    Text('你和 ${widget.otherUserName} 正在播放不同的视频。'),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: '对方正在播放 ',
                        children: <TextSpan>[
                          TextSpan(
                            text: widget.otherVideoTitle,
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
                        onPressed: () {
                          setState(() {
                            _isUnsyncNotificationShow = false;
                          });
                          widget.onAction();
                        },
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
}
