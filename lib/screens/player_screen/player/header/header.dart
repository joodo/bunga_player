import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/play_payload.dart';

import 'call_button.dart';
import '../../business.dart';

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
          JoinInIntent(myShare: payload.record),
        ),
        child: const Text('分享到频道'),
      );
    }

    final syncNotifier = context.read<WatcherSyncStatusNotifier>();

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
                ListenableBuilder(
                  listenable: syncNotifier,
                  builder: (context, child) {
                    final bufferingIds = syncNotifier.bufferingUserIds;
                    if (bufferingIds.isEmpty) return const SizedBox.shrink();

                    String bufferingUserName = '多个人';
                    if (bufferingIds.length == 1) {
                      final user = users.firstWhereOrNull(
                        (u) => u.id == bufferingIds.first,
                      );
                      bufferingUserName = user?.name ?? '神秘人';
                    }
                    return Text('等待$bufferingUserName缓冲中……').breath();
                  },
                ),
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
    /*
    final isTalking = context.select<List<TalkerId>, bool>(
      (value) => value.any((e) => e.value == user.id),
    );
    return Text(
      isTalking ? '🎤${user.name}' : user.name,
    ).textColor(user.getColor(brightness: 0.95)).padding(right: 10.0);
    */
    final syncNotifier = context.read<WatcherSyncStatusNotifier>();
    return [
      Text(user.name).textColor(user.getColor(brightness: 0.95)),
      ListenableBuilder(
        listenable: syncNotifier,
        builder: (context, child) {
          final status = syncNotifier.syncStatusOf(user.id);
          switch (status) {
            case .buffering:
              return const Text('⏳');
            case .detached:
              return const Text('⏸️');
            case _:
              return const SizedBox.shrink();
          }
        },
      ),
    ].toRow().padding(right: 10.0);
  }
}
