import 'package:animations/animations.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/player_screen/panel/audio_track_panel.dart';
import 'package:bunga_player/screens/player_screen/panel/subtitle_panel.dart';
import 'package:bunga_player/screens/player_screen/panel/video_eq_panel.dart';
import 'package:bunga_player/screens/player_screen/panel/video_source_panel.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import '../actions.dart';
import '../business.dart';

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
        final menuChildren = [
          if (!isLocalVideo) ...[
            // Reload button
            MenuItemButton(
              leadingIcon: const Icon(Icons.refresh),
              onPressed: Actions.handler(
                context,
                OpenVideoIntent.record(payload!.record),
              ),
              child: const Text('重新载入    '),
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
                  ShowPanelIntent(builder: (context) => const SubtitlePanel()),
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
            child: const Text('退出放映'),
          ),
        ];
        return builder(context, menuChildren, child);
      },
      child: child,
    );
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
