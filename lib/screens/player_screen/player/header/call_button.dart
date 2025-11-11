import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/ui/global_business.dart';
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

class CallButton extends StatefulWidget {
  const CallButton({super.key});

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  final _overlayController = OverlayPortalController();
  final _overlayVisibleNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _overlayVisibleNotifier.addListener(() {
      final showHUDNotifier = context.read<ShouldShowHUDNotifier>();
      if (_overlayVisibleNotifier.value) {
        _overlayController.show();
        showHUDNotifier.lockUp('call button');
      } else {
        _overlayController.hide();
        showHUDNotifier.unlock('call button');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonKey = GlobalKey();

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        final item = Consumer<CallStatus>(
          builder: (context, callStatus, child) => switch (callStatus) {
            CallStatus.none => [const SizedBox.shrink()],
            CallStatus.callIn => [
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
                    .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
                    .padding(vertical: 16.0, horizontal: 16.0)
              ],
            CallStatus.callOut => [
                const Text('正在呼叫')
                    .textStyle(Theme.of(context).textTheme.bodyLarge!)
                    .breath()
                    .padding(top: 16.0)
                    .center(),
                _createCallOperateButton(
                  color: Colors.red,
                  icon: Icons.call_end,
                  onPressed: Actions.handler(
                    context,
                    const CancelCallingRequestIntent(),
                  ),
                ).padding(vertical: 16.0).center(),
              ],
            CallStatus.talking => [
                Consumer<AgoraClient>(
                    builder: (context, client, child) => ValueListenableBuilder(
                        valueListenable: client.volumeNotifier,
                        builder: (context, volume, child) => SliderItem(
                              icon: Icons.headphones,
                              title: '语音音量',
                              value: volume.volume.toDouble(),
                              label: '${volume.volume}%',
                              max: 100.0,
                              onChangeStart: (value) {
                                context
                                    .read<ShouldShowHUDNotifier>()
                                    .lockUp('voice slider');
                              },
                              onChanged: (double value) {
                                final newVolume = Volume(volume: value.toInt());
                                Actions.invoke(
                                  context,
                                  UpdateVoiceVolumeIntent(newVolume),
                                );
                              },
                              onChangeEnd: (value) {
                                Actions.invoke(
                                  context,
                                  UpdateVoiceVolumeIntent.save(),
                                );
                                context
                                    .read<ShouldShowHUDNotifier>()
                                    .unlock('voice slider');
                              },
                            ).padding(horizontal: 16.0))),
                const Divider(),
                [
                  Consumer<AgoraClient>(
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
                      _overlayVisibleNotifier.value = false;
                    },
                    icon: Icon(Icons.settings),
                  ),
                ]
                    .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
                    .padding(top: 8.0, bottom: 12.0, horizontal: 12.0),
              ],
          }
              .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch),
        );

        final renderBox =
            buttonKey.currentContext!.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(
          Offset(renderBox.size.width, renderBox.size.height),
        );

        final overlay = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _overlayVisibleNotifier.value = false,
          child: [
            item.card(elevation: 4.0).positioned(
                  width: 220.0,
                  left: offset.dx - 220.0,
                  top: offset.dy,
                )
          ].toStack(),
        );
        return overlay;
      },
      child: Consumer<CallStatus>(
        key: buttonKey,
        builder: (context, callStatus, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _overlayVisibleNotifier.value = callStatus != CallStatus.none;
          });

          return switch (callStatus) {
            CallStatus.none => IconButton.filled(
                onPressed: () {
                  final watcherIds =
                      context.read<List<User>>().map((e) => e.id).toList();
                  final myId = context.read<ClientAccount>().id;

                  Actions.invoke(
                    context,
                    StartCallingRequestIntent(
                        hopeList: watcherIds..remove(myId)),
                  );
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
                onPressed: () => _overlayVisibleNotifier.value = true,
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
                onPressed: () => _overlayVisibleNotifier.value = true,
                icon: Icon(Icons.phone),
              ),
          };
        },
      ),
    );
  }

  @override
  void dispose() {
    _overlayVisibleNotifier.dispose();
    super.dispose();
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
