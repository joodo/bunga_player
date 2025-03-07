import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/voice_call/business.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/screens/widgets/slider_item.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

import '../../actions.dart';
import '../../panel/calling_settings.dart';

class CallButton extends StatelessWidget {
  const CallButton({super.key});

  @override
  Widget build(BuildContext context) {
    final callStatus = context.watch<CallStatus>();

    final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
    if (callStatus == CallStatus.callIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tooltipkey.currentState?.ensureTooltipVisible();
      });
    }

    return Tooltip(
      key: tooltipkey,
      decoration: callStatus == CallStatus.none
          ? null
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withAlpha(215),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
      enableTapToDismiss: false,
      triggerMode: TooltipTriggerMode.manual,
      richMessage: callStatus == CallStatus.none
          ? const TextSpan(text: '开始通话')
          : WidgetSpan(
              child: switch (callStatus) {
                CallStatus.none => throw UnimplementedError(),
                CallStatus.callIn => [
                    const Text('收到语音通话请求')
                        .textStyle(Theme.of(context).textTheme.bodyLarge!)
                        .breath()
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
                        .toRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween)
                        .padding(top: 24.0)
                  ],
                CallStatus.callOut => [
                    const Text('正在呼叫')
                        .textStyle(Theme.of(context).textTheme.bodyLarge!)
                        .breath()
                        .center(),
                    _createCallOperateButton(
                      color: Colors.red,
                      icon: Icons.call_end,
                      onPressed: Actions.handler(
                        context,
                        const CancelCallingRequestIntent(),
                      ),
                    ).padding(top: 24.0).center(),
                  ],
                CallStatus.talking => [
                    SliderItem(
                      icon: Icons.headphones,
                      title: '语音音量',
                      slider: Consumer<AgoraClient>(
                        builder: (context, client, child) {
                          return ValueListenableBuilder(
                            valueListenable: client.volumeNotifier,
                            builder: (context, volume, child) {
                              return Slider(
                                max: 100,
                                value: volume.volume.toDouble(),
                                label: '${volume.volume}%',
                                onChanged: (double value) {
                                  client.volumeNotifier.value =
                                      Volume(volume: value.toInt());
                                },
                                onChangeEnd: (value) {
                                  final pref = getIt<Preferences>();
                                  pref.set('call_volume', value.toInt());
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 16.0),
                    [
                      Consumer<AgoraClient>(
                        builder: (context, client, child) =>
                            ValueListenableBuilder(
                          valueListenable: client.micMuteNotifier,
                          builder: (context, muted, child) => muted
                              ? IconButton(
                                  style: const ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll<Color>(
                                            Colors.red),
                                  ),
                                  color: Colors.white70,
                                  onPressed: () {
                                    client.micMuteNotifier.value = false;
                                  },
                                  icon: Icon(Icons.mic_off),
                                )
                              : IconButton.outlined(
                                  onPressed: () {
                                    client.micMuteNotifier.value = true;
                                  },
                                  icon: Icon(Icons.mic),
                                ),
                        ),
                      ),
                      _createCallOperateButton(
                        color: Colors.red,
                        icon: Icons.call_end,
                        onPressed: Actions.handler(
                          context,
                          const HangUpIntent(),
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: () {
                          Actions.invoke(
                            context,
                            ShowPanelIntent(
                              builder: (context) => CallingSettingsPanel(),
                            ),
                          );
                          Tooltip.dismissAllToolTips();
                        },
                        icon: Icon(Icons.settings),
                      ),
                    ]
                        .toRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween)
                        .padding(top: 8.0),
                  ],
              }
                  .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
                  .padding(all: 8.0)
                  .constrained(width: 200.0),
            ),
      child: switch (callStatus) {
        CallStatus.none => IconButton(
            onPressed: () {
              final watcherIds =
                  context.read<List<User>>().map((e) => e.id).toList();
              final myId = context.read<ClientAccount>().id;

              Actions.invoke(
                context,
                StartCallingRequestIntent(hopeList: watcherIds..remove(myId)),
              );
              tooltipkey.currentState?.ensureTooltipVisible();
            },
            icon: Icon(Icons.phone),
          ),
        CallStatus.callIn ||
        CallStatus.callOut =>
          AnimateWidgetExtensions(IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
            ),
            color: Colors.white70,
            onPressed: () {
              tooltipkey.currentState?.ensureTooltipVisible();
            },
            icon: Icon(Icons.phone),
          ))
              .animate(
                onPlay: (controller) {
                  controller.repeat();
                },
              )
              .then(delay: 1000.ms)
              .shake(duration: 1500.ms),
        CallStatus.talking => IconButton(
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
            ),
            color: Colors.white70,
            onPressed: () {
              tooltipkey.currentState?.ensureTooltipVisible();
            },
            icon: Icon(Icons.phone),
          ),
      },
    );
  }

  Widget _createCallOperateButton({
    final VoidCallback? onPressed,
    required final Color color,
    required final IconData icon,
  }) =>
      IconButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(color),
        ),
        color: Colors.white70,
        icon: Icon(icon),
        onPressed: onPressed,
      ).constrained(width: 80.0);
}
