import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/play/global_business.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/player_screen/panel/audio_track_panel.dart';
import 'package:bunga_player/screens/player_screen/panel/subtitle_panel.dart';
import 'package:bunga_player/screens/player_screen/panel/video_eq_panel.dart';
import 'package:bunga_player/screens/player_screen/panel/video_source_panel.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';

import '../../actions.dart';
import '../../business.dart';

class MenuBuilder extends SingleChildStatelessWidget {
  final Widget Function(
    BuildContext context,
    List<Widget> menuChildren,
    Widget? child,
  )
  builder;

  const MenuBuilder({super.key, super.child, required this.builder});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<PlayPayload?>(
      builder: (BuildContext context, PlayPayload? payload, Widget? child) {
        final isLocalVideo = {'local', null}.contains(payload?.record.source);
        final isAgoraBackend =
            context.read<PlayerBackendNotifier>().value == .agoraMediaPlayer;

        final menuChildren = [
          if (!kIsDesktop) ...[
            MenuItemButton(
              leadingIcon: const Icon(Icons.question_mark),
              onPressed: () => _showHelp(context),
              child: const Text('触屏操作说明    '),
            ),
            const Divider(),
          ],
          if (!isLocalVideo) ...[
            // Reload button
            MenuItemButton(
              leadingIcon: const Icon(Icons.refresh),
              onPressed: Actions.handler(
                context,
                OpenVideoIntent.record(
                  payload!.record,
                  start: getIt<MediaPlayer>().positionNotifier.value,
                ),
              ),
              child: const Text('重新载入'),
            ),

            // Source button
            MenuItemButton(
              leadingIcon: const Icon(Icons.rss_feed),
              onPressed: Actions.handler(
                context,
                ShowPanelIntent(builder: (context) => const VideoSourcePanel()),
              ),
              child: Text('片源 (${payload.sources.videos.length})'),
            ),

            const Divider(),
          ],

          if (!isAgoraBackend)
            SubmenuButton(
              leadingIcon: const Icon(Icons.tune),
              menuChildren: [
                // Video button
                MenuItemButton(
                  leadingIcon: const Icon(Icons.image),
                  onPressed: Actions.handler(
                    context,
                    ShowPanelIntent(builder: (context) => const VideoEqPanel()),
                  ),
                  child: const Text('画面   '),
                ),
                // Audio button
                MenuItemButton(
                  leadingIcon: const Icon(Icons.music_note),
                  onPressed: Actions.handler(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const AudioTrackPanel(),
                    ),
                  ),
                  child: const Text('音轨'),
                ),
                // Subtitle Button
                MenuItemButton(
                  leadingIcon: const Icon(Icons.subtitles),
                  onPressed: Actions.handler(
                    context,
                    ShowPanelIntent(
                      builder: (context) => const SubtitlePanel(),
                    ),
                  ),
                  child: const Text('字幕'),
                ),
              ],
              child: const Text('调整'),
            ),

          // Change Video Button
          MenuItemButton(
            leadingIcon: const Icon(Icons.movie_filter),
            onPressed: _changeVideo(context, context.read<IsInChannel>().value),
            child: const Text('换片'),
          ),

          // Leave Button
          MenuItemButton(
            leadingIcon: const Icon(Icons.logout),
            onPressed: Navigator.of(context).maybePop,
            child: const Text('退出放映    '),
          ),
        ];
        return builder(context, menuChildren, child);
      },
      child: child,
    );
  }

  void _showHelp(BuildContext context) {
    late final OverlayEntry overlay;
    overlay = OverlayEntry(
      builder: (context) {
        return _HelpOverlay(hide: overlay.remove);
      },
    );

    Overlay.of(context).insert(overlay);
  }

  VoidCallback _changeVideo(BuildContext context, bool isCurrentSharing) {
    return () async {
      final result = await showModal<OpenVideoDialogResult>(
        context: context,
        builder: (BuildContext context) => Dialog.fullscreen(
          child: OpenVideoDialog(
            forceShareToChannel: isCurrentSharing,
          ).safeArea(),
        ),
      );
      if (result == null || !context.mounted) return;

      if (result.onlyForMe) {
        Actions.invoke(context, OpenVideoIntent.url(result.url));
      } else {
        Actions.invoke(context, ShareVideoIntent.url(result.url));
      }
    };
  }
}

class _HelpOverlay extends StatefulWidget {
  final VoidCallback hide;
  const _HelpOverlay({required this.hide});
  @override
  State<_HelpOverlay> createState() => _HelpOverlayState();
}

class _HelpOverlayState extends State<_HelpOverlay> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      [
        _createVerticalHint('单击', 'tap', '隐藏/显示进度条'),
        _createVerticalHint('双击', 'double_tap', '暂停/恢复播放'),
        _createVerticalHint('双击并按住', 'tap_hold', '抒发感觉'),
        _createVerticalHint('左右拖拽', 'horizontal_swipe', '调整进度'),
      ].toRow(mainAxisAlignment: .spaceAround, crossAxisAlignment: .center),
      [
        _createHorizontalHint(
          '滑动',
          'vertical_swipe',
          '调节亮度',
        ).center().expanded(),
        const VerticalDivider(),
        _createHorizontalHint(
          '滑动',
          'vertical_swipe',
          '调节音量',
        ).center().expanded(),
      ].toRow(crossAxisAlignment: .center),
      [
        Text(
          '语音时',
          style: Theme.of(context).textTheme.displayMedium,
        ).padding(vertical: 16.0),
        [
          _createHorizontalHint(
            '双指滑动',
            'two_finger_vertical_swipe',
            '调节媒体音量',
          ).center().expanded(),
          const VerticalDivider(),
          _createHorizontalHint(
            '双指滑动',
            'two_finger_vertical_swipe',
            '调节语音音量',
          ).center().expanded(),
        ].toRow(crossAxisAlignment: .stretch).expanded(),
      ].toColumn(crossAxisAlignment: .center),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_index < _pages.length - 1) {
          setState(() {
            _index++;
          });
        } else {
          widget.hide();
        }
      },
      child: IndexedStack(index: _index, sizing: .expand, children: _pages)
          .backgroundColor(Colors.black45)
          .backgroundBlur(20.0)
          .clipRRect(all: 24.0)
          .padding(all: 12.0),
    );
  }

  Widget _createVerticalHint(String title, String asset, String discription) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.headlineMedium!;

    return [
      Text(title, style: textStyle),
      SvgPicture.asset(
        'assets/images/gestures/$asset.svg',
        width: 120.0,
        colorFilter: ColorFilter.mode(textStyle.color!, BlendMode.srcIn),
      ),
      Text(discription, style: textStyle),
    ].toColumn(crossAxisAlignment: .center, mainAxisSize: .min);
  }

  Widget _createHorizontalHint(String title, String asset, String discription) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.headlineMedium!;
    return [
      SvgPicture.asset(
        'assets/images/gestures/$asset.svg',
        width: 120.0,
        colorFilter: ColorFilter.mode(textStyle.color!, BlendMode.srcIn),
      ),
      [
        Text(title, style: textStyle),
        Text(discription, style: textStyle),
      ].toColumn(mainAxisSize: .min),
    ].toRow(crossAxisAlignment: .center, mainAxisSize: .min);
  }
}
