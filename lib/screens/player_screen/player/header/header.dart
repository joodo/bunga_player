import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/play_payload.dart';

import '../../actions.dart';
import 'call_button.dart';

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
      [
        Text(payload.record.title)
            .textStyle(Theme.of(context).textTheme.titleMedium!)
            .padding(left: 12.0, vertical: 4.0),
        [
          Tooltip(
            message: '点击同步播放进度',
            child: TextButton(
              onPressed: () {
                Actions.invoke(context, RefreshWatchersIntent());
                Actions.invoke(context, AskPositionIntent());
              },
              child: const Text('当前观众:')
                  .textColor(Theme.of(context).colorScheme.onSurface),
            ),
          ),
          ...users.map((user) => _WatcherLabel(user)),
        ].toRow(),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .padding(horizontal: 8.0),
      const Spacer(),
      const CallButton().padding(right: 16.0),
    ].toRow();
  }
}

class _WatcherLabel extends StatelessWidget {
  final User user;
  const _WatcherLabel(this.user);

  @override
  Widget build(BuildContext context) {
    final isTalking = context.select<List<TalkerId>, bool>(
      (value) => value.any((e) => e.value == user.id),
    );
    return Text(isTalking ? '🎤${user.name}' : user.name)
        .textColor(user.getColor(brightness: 0.95))
        .padding(right: 10.0);
  }
}
