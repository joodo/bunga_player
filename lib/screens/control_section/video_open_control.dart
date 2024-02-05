import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/screens/dialogs/bili_dialog.dart';
import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/actions/open_local_video.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/business/remote_playing.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoOpenControl extends StatefulWidget {
  const VideoOpenControl({super.key});

  @override
  State<VideoOpenControl> createState() => _VideoOpenControlState();
}

class _VideoOpenControlState extends State<VideoOpenControl> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        ),
        Selector<BusinessIndicator, bool>(
          selector: (context, bi) => bi.currentProgress != null,
          builder: (context, isBusy, child) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: isBusy ? null : _openLocalVideo,
                child: const Text('视频文件'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: isBusy ? null : _openBilibili,
                child: const Text('Bilibili 视频'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openLocalVideo() async {
    final currentChannel = context.read<CurrentChannel>();
    final videoPlayer = context.read<VideoPlayer>();
    final playerController = context.read<RemotePlaying>();
    final bi = context.read<BusinessIndicator>();

    final shouldUpdateChannelData = playerController.isVideoSameWithRoom;

    final file = await openLocalVideoDialog();
    if (file == null) return;

    await bi.run(
      missions: [
        Mission(
          name: '正在收拾客厅……',
          tasks: [
            () => videoPlayer.loadLocalVideo(file),
          ],
        ),
        Mission(
          name: '正在发送请柬……',
          tasks: [
            () async {
              // Update room data only if playing correct video
              if (shouldUpdateChannelData) {
                await currentChannel.updateData(ChannelData(
                  videoType: VideoType.local,
                  name: file.name,
                  videoHash: videoPlayer.videoHashNotifier.value!,
                ));
              } else {
                playerController.askPosition();
              }
            },
          ],
        ),
      ],
      onError: () {
        context.showToast('加载失败');
      },
    );

    _onVideoLoaded();
  }

  void _openBilibili() async {
    final currentChannel = context.read<CurrentChannel>();
    final videoPlayer = context.read<VideoPlayer>();
    final playerController = context.read<RemotePlaying>();
    final bi = context.read<BusinessIndicator>();
    final showToast = context.showToast;

    // Update room data only if playing correct video
    final shouldUpdateRoomData = playerController.isVideoSameWithRoom;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => const BiliDialog(),
    );
    if (result == null) return;

    final biliEntry =
        await getService<Bilibili>().getEntryFromUri(result.parseUri());
    await bi.run(
      missions: [
        Mission(
          name: '正在鬼鬼祟祟……',
          tasks: [
            () async {
              videoPlayer.stop();

              await getService<Bilibili>().fetch(biliEntry);
              if (biliEntry is BiliVideo && !(biliEntry).isHD) {
                showToast('无法获取高清视频');
              }
            },
          ],
        ),
        Mission(name: '正在收拾客厅……', tasks: [
          () async {
            await videoPlayer.loadBiliVideo(biliEntry);

            if (shouldUpdateRoomData) {
              await currentChannel.updateData(ChannelData(
                videoType: VideoType.bilibili,
                name: biliEntry.title,
                videoHash: biliEntry.hash,
                pic: biliEntry.pic,
              ));
            } else {
              // if it's me that updated channel data, then no need to ask
              playerController.askPosition();
            }
          },
        ]),
      ],
      onError: () => showToast('解析失败'),
    );

    _onVideoLoaded();
  }

  void _onVideoLoaded() {
    Navigator.of(context).pop();
  }
}
