import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/screens/widgets/widgets.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/voice_call/client/client.dart';

import '../actions.dart';
import '../panel/calling_settings.dart';

class CallButton extends StatefulWidget {
  const CallButton({super.key});

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  final _overlayVisibleNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
    _overlayVisibleNotifier.addListener(() {
      if (_overlayVisibleNotifier.value) {
        showHUDNotifier.lockUp('call button');
      } else {
        showHUDNotifier.unlock('call button');
      }
    });
  }

  @override
  void dispose() {
    _overlayVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget overlayBuilder(BuildContext context) {
      return Consumer<CallStatus>(
        builder: (context, callStatus, child) =>
            switch (callStatus) {
                  .none => [const SizedBox.shrink()],
                  .callIn => _createCallInItems(context),
                  .callOut => _createCallOutItems(context),
                  .talking => _createTalkingItems(context),
                }
                .toColumn(crossAxisAlignment: .stretch)
                .card(elevation: 4.0)
                .constrained(width: 220.0),
      );
    }

    final button = Consumer<CallStatus>(
      builder: (context, callStatus, child) => switch (callStatus) {
        .none => IconButton.filled(
          onPressed: () {
            final watcherIds = context
                .read<Watchers>()
                .map((e) => e.id)
                .toList();
            final myId = context.read<ClientAccount>().id;

            Actions.invoke(
              context,
              StartCallingRequestIntent(hopeList: watcherIds..remove(myId)),
            );
          },
          icon: Icon(Icons.phone),
        ),
        .callIn || .callOut =>
          AnimateWidgetExtensions(
                IconButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Colors.green,
                    ),
                  ),
                  color: Colors.white70,
                  onPressed: () => _overlayVisibleNotifier.value = true,
                  icon: Icon(Icons.phone),
                ),
              )
              .animate(
                onPlay: (controller) {
                  controller.repeat();
                },
              )
              .then(delay: 1000.ms)
              .shake(duration: 1500.ms),
        .talking => Consumer<VoiceCallClient>(
          builder: (context, client, child) => ValueListenableBuilder(
            valueListenable: client.micMuteNotifier,
            builder: (context, muted, child) => IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  muted ? Colors.yellow[800]! : Colors.green,
                ),
              ),
              color: Colors.white70,
              onPressed: () => _overlayVisibleNotifier.value = true,
              icon: Icon(Icons.phone),
            ),
          ),
        ),
      },
    );

    final link = LayerLink();
    final popup = ValueListenableBuilder(
      valueListenable: _overlayVisibleNotifier,
      builder: (context, visible, child) => PopupWidget(
        showing: visible,
        popupBuilder: overlayBuilder,
        layoutBuilder: (context, popup) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _overlayVisibleNotifier.value = false,
          child: UnconstrainedBox(
            child: CompositedTransformFollower(
              link: link,
              targetAnchor: .bottomRight,
              followerAnchor: .topRight,
              child: popup,
            ),
          ),
        ),
        child: child,
      ),
      child: CompositedTransformTarget(link: link, child: button),
    );

    return popup.listenProvider<CallStatus>(
      (context, value) =>
          runAfterBuild(() => _overlayVisibleNotifier.value = value != .none),
    );
  }

  List<Widget> _createCallInItems(BuildContext context) => [
    const Text('收到语音通话请求')
        .textStyle(Theme.of(context).textTheme.bodyLarge!)
        .breath()
        .padding(top: 16.0)
        .center(),
    [
          _createCallOperateButton(
            color: Colors.green,
            icon: Icons.call,
            onPressed: Actions.handler(
              context,
              const AcceptCallingRequestIntent(),
            ),
          ),
          _createCallOperateButton(
            color: Colors.red,
            icon: Icons.call_end,
            onPressed: Actions.handler(
              context,
              const RejectCallingRequestIntent(),
            ),
          ),
        ]
        .toRow(mainAxisAlignment: .spaceBetween)
        .padding(vertical: 16.0, horizontal: 16.0),
  ];

  List<Widget> _createCallOutItems(BuildContext context) => [
    const Text('正在呼叫')
        .textStyle(Theme.of(context).textTheme.bodyLarge!)
        .breath()
        .padding(top: 16.0)
        .center(),
    _createCallOperateButton(
      color: Colors.red,
      icon: Icons.call_end,
      onPressed: Actions.handler(context, const CancelCallingRequestIntent()),
    ).padding(vertical: 16.0).center(),
  ];

  List<Widget> _createTalkingItems(BuildContext context) => [
    Consumer<VoiceCallClient>(
      builder: (context, client, child) => ValueListenableBuilder(
        valueListenable: client.volumeNotifier,
        builder: (context, volume, child) => SliderItem(
          icon: Icons.headphones,
          title: '语音音量',
          value: volume.level,
          label: '${volume.level.toLevel}%',
          onChangeStart: (value) {
            context.read<ShouldShowHUDNotifier>().lockUp('voice slider');
          },
          onChanged: (double value) {
            final newVolume = Volume(level: value);
            Actions.invoke(context, UpdateVoiceVolumeIntent(newVolume));
          },
          onChangeEnd: (value) {
            Actions.invoke(context, FinishUpdateVoiceVolumeIntent());
            context.read<ShouldShowHUDNotifier>().unlock('voice slider');
          },
        ).padding(horizontal: 16.0),
      ),
    ),
    const Divider(),
    [
          Consumer<VoiceCallClient>(
            builder: (context, client, child) => ValueListenableBuilder(
              valueListenable: client.micMuteNotifier,
              builder: (context, muted, child) => IconButton.outlined(
                style: const ButtonStyle(
                  backgroundColor: WidgetStateProperty.fromMap({
                    WidgetState.selected: Colors.red,
                    WidgetState.any: null,
                  }),
                ),
                isSelected: muted,
                color: Colors.white70,
                onPressed: Actions.handler(context, ToggleMicIntent()),
                icon: Icon(muted ? Icons.mic_off : Icons.mic),
              ),
            ),
          ),
          _createCallOperateButton(
            color: Colors.red,
            icon: Icons.call_end,
            onPressed: Actions.handler(context, const HangUpIntent()),
          ),
          IconButton.outlined(
            onPressed: () {
              Actions.invoke(
                context,
                ShowPanelIntent(builder: (context) => CallingSettingsPanel()),
              );
              _overlayVisibleNotifier.value = false;
            },
            icon: Icon(Icons.settings),
          ),
        ]
        .toRow(mainAxisAlignment: .spaceBetween)
        .padding(top: 8.0, bottom: 12.0, horizontal: 12.0),
  ];

  Widget _createCallOperateButton({
    final VoidCallback? onPressed,
    required final Color color,
    required final IconData icon,
  }) => IconButton(
    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(color)),
    color: Colors.white70,
    icon: Icon(icon),
    onPressed: onPressed,
  ).constrained(width: 80.0);
}
