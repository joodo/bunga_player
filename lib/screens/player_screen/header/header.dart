import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/screens/player_screen/business.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/play_payload.dart';

import 'call_button.dart';

class Header extends StatelessWidget {
  static const height = 54.0;
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final payload = context.watch<PlayPayload?>();
    if (payload == null) return const SizedBox.shrink();

    if (!context.watch<IsInChannel>().value) {
      return TextButton(
        onPressed: Actions.handler(
          context,
          JoinInIntent(myRecord: payload.record),
        ),
        child: const Text('分享到频道'),
      );
    }

    return Consumer<Watchers>(
          builder: (context, users, child) => [
            Text(payload.record.title, maxLines: 1, overflow: .ellipsis)
                .textStyle(Theme.of(context).textTheme.titleLarge!)
                .padding(right: 12.0)
                .expanded(),
            const Text(
              '当前观众：',
            ).textColor(Theme.of(context).colorScheme.onSurface),
            ...users.map((user) => _WatcherLabel(user)),
            const SizedBox(width: 12.0),
            CallButton(),
          ].toRow(),
        )
        .padding(horizontal: 16.0)
        .backgroundGradient(
          LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            stops: [0.2, 1.0],
            colors: [Colors.black, Colors.transparent],
          ),
        )
        .constrained(height: height);
  }
}

class _WatcherLabel extends StatelessWidget {
  final User user;
  const _WatcherLabel(this.user);

  @override
  Widget build(BuildContext context) {
    final idsNotifier = context.read<WatcherPendingIdsNotifier>();
    return [
      Selector<List<TalkerId>, bool>(
        selector: (context, value) => value.any((e) => e.value == user.id),
        builder: (context, isTalking, child) =>
            isTalking ? Text('🎤') : const SizedBox.shrink(),
      ),
      Text(user.name).textColor(user.getColor(brightness: 0.95)),
      ValueListenableBuilder(
        valueListenable: idsNotifier,
        builder: (context, ids, child) =>
            ids.contains(user.id) ? const Text('⏳') : const SizedBox.shrink(),
      ),
    ].toRow().padding(right: 8.0);
  }
}
