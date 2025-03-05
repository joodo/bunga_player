import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/screens/player_screen/actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final payload = context.watch<PlayPayload?>();
    if (payload == null) return const SizedBox.shrink();

    final users = context.watch<List<User>?>();
    if (users == null) {
      return TextButton(
        onPressed: Actions.handler(
          context,
          ShareVideoIntent(payload.record),
        ),
        child: const Text('分享到频道'),
      );
    }

    return [
      Tooltip(
        message: '刷新',
        verticalOffset: 20.0,
        child: TextButton(
          onPressed: Actions.handler(context, RefreshWatchersIntent()),
          child: const Text('当前观众:')
              .textColor(Theme.of(context).colorScheme.onSurface),
        ),
      ),
      ...users.map((user) => _WatcherLabel(user) as Widget),
      TextButton(
        onPressed: Actions.handler(context, AskPositionIntent()),
        child: const Text('同步播放进度'),
      ),
    ].toRow().padding(horizontal: 8.0);
  }
}

class _WatcherLabel extends StatelessWidget {
  final User user;
  const _WatcherLabel(this.user);

  @override
  Widget build(BuildContext context) {
    return Text(user.name)
        .textColor(user.getColor(brightness: 0.95))
        .padding(right: 10.0);
  }
}
