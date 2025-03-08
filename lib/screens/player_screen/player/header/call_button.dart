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

class CallButton extends StatefulWidget {
  const CallButton({super.key});

  @override
  State<CallButton> createState() => _CallButtonState();
}

class _CallButtonState extends State<CallButton> {
  final _overlayController = OverlayPortalController();

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
                    builder: (context, client, child) => ValueListenableBuilder(
                      valueListenable: client.micMuteNotifier,
                      builder: (context, muted, child) => muted
                          ? IconButton(
                              style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll<Color>(Colors.red),
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
                      _overlayController.hide();
                    },
                    icon: Icon(Icons.settings),
                  ),
                ]
                    .toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween)
                    .padding(top: 8.0),
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
          onTap: _overlayController.hide,
          child: [
            item
                .padding(horizontal: 12.0, top: 8.0, bottom: 12.0)
                .card(elevation: 4.0)
                .positioned(
                  width: 220.0,
                  left: offset.dx - 220.0,
                  top: offset.dy + 12.0,
                )
          ].toStack(),
        );
        return overlay;
      },
      child: Consumer<CallStatus>(
        key: buttonKey,
        builder: (context, callStatus, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (callStatus != CallStatus.none) {
              _overlayController.show();
            } else {
              _overlayController.hide();
            }
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
                onPressed: _overlayController.show,
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
                onPressed: _overlayController.show,
                icon: Icon(Icons.phone),
              ),
          };
        },
      ),
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
