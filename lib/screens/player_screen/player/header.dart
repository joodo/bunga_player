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
    final users = context.watch<List<User>?>();
    return users == null
        ? TextButton(
            onPressed: Actions.handler(
              context,
              ShareVideoIntent(context.read<PlayPayload>().record),
            ),
            child: const Text('分享到频道'),
          )
        : [
            Tooltip(
              message: '刷新',
              child: TextButton(
                onPressed: Actions.handler(context, RefreshWatchersIntent()),
                child: Text(
                  '当前观众:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            ...users.map((user) => _WatcherLabel(user) as Widget),
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
        .padding(right: 8.0);
  }
}
