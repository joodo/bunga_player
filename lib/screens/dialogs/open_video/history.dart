import 'package:bunga_player/play/models/history.dart';
import 'package:bunga_player/utils/extensions/datetime.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'open_video.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = context.read<History>().value;

    if (history.isEmpty) {
      return const Text('暂无历史').textStyle(theme.textTheme.labelLarge!);
    }

    final entries = history.values
        .sortedBy((element) => element.updatedAt)
        .reversed
        .toList();
    return ListView.builder(
      itemCount: history.length,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemBuilder: (BuildContext context, int index) {
        final entry = entries[index];
        return Dismissible(
          key: Key(index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            history.remove(entry.videoRecord.id);
          },
          child: ListTile(
            leading: (entry.videoRecord.thumbUrl == null
                    ? const Icon(Icons.movie_creation_outlined)
                        .iconSize(32.0)
                        .center()
                    : Image.network(
                        entry.videoRecord.thumbUrl!,
                        fit: BoxFit.cover,
                        height: double.maxFinite,
                      ))
                .constrained(width: 60)
                .clipRRect(all: 16.0),
            title: Text(entry.videoRecord.title),
            subtitle: Text(entry.updatedAt.relativeString),
            trailing: Text('已看 ${(entry.progress.ratio * 100).toInt()}%'),
            onTap: Actions.handler(
                context,
                SelectUrlIntent(Uri(
                  scheme: 'history',
                  path: entry.videoRecord.id,
                ))),
          ),
        );
      },
    ).material(color: theme.colorScheme.surfaceContainer);
  }
}
