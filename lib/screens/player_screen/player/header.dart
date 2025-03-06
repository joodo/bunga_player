import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/screens/player_screen/actions.dart';
import 'package:bunga_player/screens/widgets/slider_item.dart';
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
      StyledWidget(Tooltip(
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor.withAlpha(215),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        enableTapToDismiss: false,
        triggerMode: TooltipTriggerMode.manual,
        richMessage: WidgetSpan(
          child: [
            SliderItem(
              icon: Icons.volume_down,
              title: '语音音量',
              slider: Slider(
                value: 0.5,
                onChanged: (double value) {},
              ),
            ),
          ]
              .toColumn()
              .padding(left: 4.0, bottom: 8.0)
              .constrained(width: 200.0),
        ),
        child: IconButton.filled(
          onPressed: () {},
          icon: Icon(Icons.phone),
        ),
      )).padding(right: 16.0),
    ].toRow();
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
