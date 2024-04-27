import 'dart:async';
import 'dart:typed_data';

import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/clients/chat.dart';
import 'package:bunga_player/screens/widgets/scroll_optimizer.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/http_response.dart';
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
  List<({String id, ChannelData data})>? _channels;
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
                if (_channels != null)
                  ..._channels!.map((channel) => _ChannelCard(
                        channelData: channel.data,
                        onTapped: () =>
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context)
                              .pop<({String id, VideoEntry entry})>(
                            (
                              id: channel.id,
                              entry: VideoEntry.fromChannelData(channel.data),
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
    // HACK: cannot use listview because issue, same as popmoji
    // https://github.com/flutter/flutter/issues/26527
    final channelsView = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: themeData.colorScheme.surface,
      ),
      child: Stack(
        children: [
          channelsScroll,
          if (_channels?.isEmpty ?? false)
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
      content: SizedBox(
        width: 500,
        height: 220,
        child: _channels == null
            ? const Center(child: CircularProgressIndicator())
            : channelsView,
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
          _channels = channels;
        });
      }
    }

    final timer = Timer.periodic(const Duration(seconds: 5), updateChannel);
    updateChannel(timer);
    return timer;
  }
}

class _ChannelCard extends StatefulWidget {
  final ChannelData channelData;
  final VoidCallback onTapped;

  const _ChannelCard({required this.channelData, required this.onTapped});

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _getNetworkImageData(widget.channelData.image ?? '');
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
                    widget.channelData.sharer.name,
                    style: themeData.textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '分享',
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
              message: widget.channelData.name,
              child: Text(
                widget.channelData.name,
                overflow: TextOverflow.ellipsis,
                style: themeData.textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ],
    );

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.hardEdge,
      color: ElevationOverlay.applySurfaceTint(
        themeData.colorScheme.surfaceVariant,
        themeData.colorScheme.surfaceTint,
        0,
      ),
      elevation: 0,
      child: InkWell(
        onTap: widget.onTapped,
        child: cardContent,
      ),
    );

    final themedCard = FutureBuilder(
      future: _imageData != null
          ? ColorScheme.fromImageProvider(
              provider: MemoryImage(_imageData!),
            )
          : null,
      initialData: themeData.colorScheme,
      builder: (context, snapshot) => Theme(
        data: themeData.copyWith(colorScheme: snapshot.data!),
        child: card,
      ),
    );

    return themedCard;
  }

  void _getNetworkImageData(String uri) async {
    try {
      final response = await http.get(Uri.parse(uri));
      if (!response.isSuccess) {
        throw Exception('image fetch failed: ${response.statusCode}');
      }
      setState(() {
        _imageData = response.bodyBytes;
      });
    } catch (e) {
      logger.w(e);
    }
  }
}
