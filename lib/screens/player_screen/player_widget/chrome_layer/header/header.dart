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

    return [
      [
            Text(payload.record.title, maxLines: 1, overflow: .ellipsis)
                .textStyle(Theme.of(context).textTheme.titleLarge!)
                .padding(vertical: 8.0),
            Consumer<Watchers>(
              builder: (context, users, child) => [
                const Text(
                  '当前观众：',
                ).textColor(Theme.of(context).colorScheme.onSurface),
                ...users.map((user) => _WatcherLabel(user)),
              ].toRow(),
            ),
          ]
          .toColumn(crossAxisAlignment: .start, mainAxisSize: .min)
          .padding(horizontal: 16.0)
          .flexible(),
      const CallButton().padding(right: 16.0),
    ].toRow().padding(vertical: 4.0);
  }
}

class _WatcherLabel extends StatelessWidget {
  final User user;
  const _WatcherLabel(this.user);

  @override
  Widget build(BuildContext context) {
    final bufferingNotifier = context.read<WatcherBufferingStatusNotifier>();
    return [
      Selector<List<TalkerId>, bool>(
        selector: (context, value) => value.any((e) => e.value == user.id),
        builder: (context, isTalking, child) =>
            isTalking ? Text('🎤') : const SizedBox.shrink(),
      ),
      Text(user.name).textColor(user.getColor(brightness: 0.95)),
      ListenableBuilder(
        listenable: bufferingNotifier,
        builder: (context, child) => bufferingNotifier.isBuffering(user.id)
            ? const Text('⏳')
            : const SizedBox.shrink(),
      ),
    ].toRow().padding(right: 10.0);
  }
}
