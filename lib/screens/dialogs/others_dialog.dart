import 'dart:async';
import 'dart:typed_data';

import 'package:bunga_player/player/models/video_entries/video_entry.dart';
import 'package:bunga_player/alist/client.dart';
import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/screens/widgets/scroll_optimizer.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/extensions/datetime.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class OthersDialog extends StatefulWidget {
  const OthersDialog({super.key});
  @override
  State<OthersDialog> createState() => OthersDialogState();
}

class OthersDialogState extends State<OthersDialog> {
  List<ChannelInfo>? _channelInfos;
  late final Timer _timer;

  final _scrollController = ScrollController();

  @override
  void initState() {
    _timer = _createUpdateTimer();
    super.initState();
  }

  @override
  dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    final channelsScroll = Scrollbar(
      controller: _scrollController,
      child: ScrollOptimizer(
        scrollController: _scrollController,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Row(
              children: [
                const SizedBox(width: 8),
                if (_channelInfos != null)
                  ..._channelInfos!.map((info) => _ChannelCard(
                        channelInfo: info,
                        onTapped: () =>
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context)
                              .pop<({String id, VideoEntry entry})>(
                            (
                              id: info.id,
                              entry: VideoEntry.fromChannelData(info.data),
                            ),
                          );
                        }),
                      )),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );

    final channelsView = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: themeData.colorScheme.surfaceContainer),
      child: Stack(
        children: [
          if (_channelInfos != null) channelsScroll,
          if (_channelInfos == null)
            const Center(child: CircularProgressIndicator()),
          if (_channelInfos?.isEmpty ?? false)
            Center(
              child: Text(
                '暂时没有其他人分享视频',
                style: themeData.textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );

    return AlertDialog(
      title: const Text('加入其他人'),
      contentPadding: const EdgeInsets.only(top: 20, bottom: 24),
      content: SizedBox(
        width: 560,
        height: 256,
        child: channelsView,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Timer _createUpdateTimer() {
    void updateChannel(_) async {
      final chatClient = context.read<ChatClient>();
      final channels = await chatClient.queryOnlineChannels();
      if (mounted) {
        setState(() {
          _channelInfos = channels;
        });
      }
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}

class _ChannelCard extends StatefulWidget {
  final ChannelInfo channelInfo;
  final VoidCallback onTapped;

  const _ChannelCard({required this.channelInfo, required this.onTapped});

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _getNetworkImageData(widget.channelInfo.data.image ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final videoImage = _imageData != null
        ? Image.memory(
            _imageData!,
            width: 200,
            height: 125,
            fit: BoxFit.cover,
          )
        : const SizedBox(
            width: 200,
            height: 125,
            child: Center(
              child: Icon(Icons.movie_creation_outlined, size: 80),
            ),
          );

    final themeData = Theme.of(context);
    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        videoImage,
        SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.channelInfo.data.sharer.name,
                    style: themeData.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  ' ${widget.channelInfo.createAt.relativeString} 分享',
                  style: themeData.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Tooltip(
              message: widget.channelInfo.data.name,
              child: Text(
                widget.channelInfo.data.name,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ],
    );

    final card = Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        clipBehavior: Clip.hardEdge,
        color: colorScheme.primaryContainer,
        child: InkWell(
          onTap: widget.onTapped,
          child: cardContent,
        ),
      );
    });

    final themedCard = FutureBuilder(
      future: _imageData != null
          ? ColorScheme.fromImageProvider(
              provider: MemoryImage(_imageData!),
              brightness: Brightness.dark,
            )
          : null,
      initialData: themeData.colorScheme,
      builder: (context, snapshot) => Theme(
        data: themeData.copyWith(colorScheme: snapshot.data),
        child: card,
      ),
    );

    return themedCard;
  }

  void _getNetworkImageData(String uriString) async {
    try {
      final uri = Uri.parse(uriString);

      if (uri.scheme == 'alist') {
        final bungaClient = context.read<BungaClient>();
        _imageData = await bungaClient.getAlistThumb(
          path: uri.path,
          alistToken: context.read<AListClient>().token,
        );
      } else {
        final response = await http.get(uri);
        if (!response.isSuccess) {
          throw Exception('image fetch failed: ${response.statusCode}');
        }
        _imageData = response.bodyBytes;
      }

      if (mounted) setState(() {});
    } catch (e) {
      logger.w(e);
    }
  }
}
