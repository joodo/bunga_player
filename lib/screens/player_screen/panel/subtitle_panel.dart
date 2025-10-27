import 'package:bunga_player/chat/client/client.tencent.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/screens/widgets/slider_item.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

class SubtitlePanel extends StatefulWidget implements Panel {
  const SubtitlePanel({super.key});

  @override
  final type = 'subtitle';

  @override
  State<SubtitlePanel> createState() => _SubtitlePanelState();
}

typedef _TuneArgumentData = ({
  IconData icon,
  String title,
  ValueNotifier<double> notifier,
  double min,
  double max,
  String Function(double value) labelFunc,
});

class _SubtitlePanelState extends State<SubtitlePanel> {
  static final _tuneArguments = <_TuneArgumentData>[
    (
      icon: Icons.timer,
      title: '延迟',
      notifier: getIt<PlayService>().subDelayNotifier,
      min: -20.0,
      max: 20.0,
      labelFunc: (value) => '${value.toStringAsFixed(2)} s',
    ),
    (
      icon: Icons.format_size,
      title: '大小',
      notifier: getIt<PlayService>().subSizeNotifier,
      min: 20.0,
      max: 72.0,
      labelFunc: (value) => value.toInt().toString(),
    ),
    (
      icon: Icons.height,
      title: '高度',
      notifier: getIt<PlayService>().subPosNotifier,
      min: -100.0,
      max: 50.0,
      labelFunc: (value) => '${value.toInt()} %',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final player = getIt<PlayService>();
    final theme = Theme.of(context);

    final tracksSection = Consumer<IsInChannel>(
        builder: (context, isInChannel, child) => ValueListenableBuilder(
              valueListenable: player.subtitleTracksNotifier,
              builder: (context, tracks, child) => ValueListenableBuilder(
                valueListenable: player.subtitleTrackNotifier,
                builder: (context, currentTrack, child) => [
                  ...tracks.where((e) => !e.id.startsWith('\$n')).map((e) =>
                      RadioListTile(
                        key: ValueKey(e.id),
                        title: Text(_toTitle(e)),
                        value: e.id,
                        groupValue: currentTrack.id,
                        secondary: isInChannel.value && e.id.startsWith('\$e')
                            ? IconButton(
                                icon: Icon(Icons.ios_share),
                                tooltip: '分享给他人',
                                onPressed: () {
                                  _shareSubtitle(e.id);
                                },
                              )
                            : null,
                        onChanged: (String? id) {
                          if (id == null) return;
                          Actions.invoke(context, SetSubtitleTrackIntent(id));
                        },
                      )),
                  if (isInChannel.value)
                    Consumer<Map<String, ChannelSubtitle>>(
                      builder: (context, channelSubtitles, child) =>
                          channelSubtitles.values
                              .map((e) => _ChannelSubtitleRadioTile(
                                    info: e,
                                    groupValue: currentTrack.id,
                                  ))
                              .toList()
                              .toColumn(),
                    ),
                ].toColumn(),
              ),
            ));

    final tuneSection = [
      const Text('调整')
          .textStyle(theme.textTheme.labelMedium!)
          .padding(horizontal: 16.0, top: 24.0, bottom: 8.0),
      ..._tuneArguments.map(
        (e) => SliderItem(
          icon: e.icon,
          title: e.title,
          slider: ValueListenableBuilder(
            valueListenable: e.notifier,
            builder: (context, value, child) => Slider(
              min: e.min,
              max: e.max,
              value: value,
              label: e.labelFunc(value),
              onChanged: (value) {
                e.notifier.value = value;
              },
            ),
          ),
        ).padding(horizontal: 16.0),
      ),
    ].toColumn();

    final body = [
      tracksSection,
      tuneSection,
    ].toColumn();

    return PanelWidget(
      title: '字幕',
      actions: [
        IconButton(
          onPressed: _openSubtitle,
          icon: const Icon(Icons.add),
          tooltip: '打开外部字幕',
        ),
      ],
      child: body.scrollable(padding: const EdgeInsets.only(bottom: 16.0)),
    );
  }

  String _toTitle(SubtitleTrack track) {
    String title = '';
    if (track.title != null) title += track.title!;
    if (track.language != null) title += ' (${track.language})';
    if (title.isEmpty) title = '[${track.id}]';
    return title;
  }

  void _openSubtitle() async {
    final file = await openFile();
    if (!context.mounted || file == null) return;

    final player = getIt<PlayService>();
    try {
      final track = await player.loadSubtitleTrack(file.path);

      if (!mounted) return;
      Actions.invoke(context, SetSubtitleTrackIntent(track.id));
    } catch (e) {
      getIt<Toast>().show('字幕载入失败');
    }
  }

  void _shareSubtitle(String trackId) async {
    final chatClient = context.read<TencentClient>();
    final path = getIt<PlayService>().subtitleTrackNotifier.value.path!;
    final me = User.fromContext(context);

    try {
      final url = await chatClient.uploadFile(path);

      final title = path_tool.basenameWithoutExtension(path);
      final messageData = ShareSubMessageData(
        url: url,
        sharer: me,
        title: title,
      );
      await chatClient.sendMessage(messageData.toJson());
      getIt<Toast>().show('分享成功');
    } catch (e) {
      getIt<Toast>().show('分享失败');
      rethrow;
    }
  }
}

class _ChannelSubtitleRadioTile extends StatefulWidget {
  final ChannelSubtitle info;
  final String groupValue;

  const _ChannelSubtitleRadioTile({
    required this.info,
    required this.groupValue,
  });

  @override
  State<_ChannelSubtitleRadioTile> createState() =>
      _ChannelSubtitleRadioTileState();
}

class _ChannelSubtitleRadioTileState extends State<_ChannelSubtitleRadioTile> {
  @override
  Widget build(BuildContext context) {
    return RadioListTile<String?>(
      title: Text('${widget.info.sharer.name} 分享：${widget.info.title}'),
      value: context.read<SubtitleTrackIdOfUrl>().value[widget.info.url],
      groupValue: widget.groupValue,
      onChanged: (String? value) {
        _loadChannelData();
      },
    );
  }

  void _loadChannelData() async {
    final busyNotifier = context.read<PanelBusyNotifier>();
    final playService = getIt<PlayService>();
    final subtitleTrackIdOfUrl = context.read<SubtitleTrackIdOfUrl>().value;
    final url = widget.info.url;
    try {
      if (subtitleTrackIdOfUrl[url] == null) {
        busyNotifier.value = true;
        final track = await playService.loadSubtitleTrack(url);
        subtitleTrackIdOfUrl[url] = track.id;
        setState(() {});
      }

      if (!mounted) return;
      final trackId = subtitleTrackIdOfUrl[url]!;
      Actions.invoke(context, SetSubtitleTrackIntent(trackId));
    } catch (e) {
      getIt<Toast>().show('分享失败');
      rethrow;
    } finally {
      busyNotifier.value = false;
    }
  }
}
