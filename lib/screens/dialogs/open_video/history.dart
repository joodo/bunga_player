import 'package:bunga_player/play/history.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/utils/extensions/datetime.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'open_video.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = context.read<History>();

    final entries = history.values
        .where((element) => element.progress != null)
        .sortedBy((element) => element.updatedAt)
        .reversed
        .toList();

    if (entries.isEmpty) {
      return const Text('暂无历史').textStyle(theme.textTheme.labelLarge!);
    }

    return ListView.builder(
      itemCount: entries.length,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemBuilder: (BuildContext context, int index) {
        final entry = entries[index];
        return Dismissible(
          key: Key(entry.videoRecord.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: .centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              history.remove(entry.videoRecord.id);
            });
          },
          child: ListTile(
            leading:
                (entry.videoRecord.thumbUrl?.isEmpty == false
                        ? Image.network(
                            entry.videoRecord.thumbUrl!,
                            fit: BoxFit.cover,
                            height: double.maxFinite,
                          )
                        : const Icon(
                            Icons.movie_creation_outlined,
                          ).iconSize(32.0).center())
                    .constrained(width: 60)
                    .clipRRect(all: 16.0),
            title: TitleWithProgress(
              title: entry.videoRecord.title,
              progress: entry.progress!.ratio,
            ).padding(bottom: 4.0),
            subtitle: Text(
              PlayPayloadParser.getFriendlyPath(entry.videoRecord),
            ),
            trailing: Text(entry.updatedAt.relativeString),
            onTap: Actions.handler(
              context,
              SelectUrlIntent(
                Uri(scheme: 'history', path: entry.videoRecord.id),
              ),
            ),
          ),
        );
      },
    ).material(color: theme.colorScheme.surfaceContainer);
  }
}

class TitleWithProgress extends StatelessWidget {
  final double progress;
  final String title;

  const TitleWithProgress({
    super.key,
    required this.progress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = DefaultTextStyle.of(context).style;
    return RichText(
      text: TextSpan(
        text: title,
        style: style,
        children: [
          const TextSpan(text: '  '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child:
                Text(
                      progress < 0.95
                          ? '已看 ${(progress * 100).toInt()}%'
                          : '已看完',
                    )
                    .textStyle(theme.textTheme.labelSmall!)
                    .padding(horizontal: 8.0, vertical: 4.0)
                    .decorated(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
          ),
        ],
      ),
    );
  }
}
