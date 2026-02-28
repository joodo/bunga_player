import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:bunga_player/voice_call/client/client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

class CallingSettingsPanel extends StatelessWidget implements Panel {
  const CallingSettingsPanel({super.key});

  @override
  final type = 'video_source';

  static const names = ['无', '低', '中', '高'];

  @override
  Widget build(BuildContext context) {
    return PanelWidget(
      title: const Text('语音设置'),
      child: Consumer<VoiceCallClient>(
        builder: (context, client, child) {
          client as AgoraClient;
          return [
            FutureBuilder(
              future: client.getAvailableInputDevices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final devices = snapshot.data!;
                return ValueListenableBuilder(
                  valueListenable: client.inputDeviceNotifier,
                  builder: (context, currentId, child) =>
                      [
                        ...devices.map(
                          (e) => RadioListTile(
                            title: Text(e.deviceName ?? '未知设备'),
                            subtitle: Text(e.deviceTypeName ?? ''),
                            value: e.deviceId,
                          ),
                        ),
                      ].toColumn().radioGroup<String?>(
                        groupValue: currentId,
                        onChanged: (value) {
                          client.inputDeviceNotifier.value = value!;
                        },
                      ),
                );
              },
            ),
            const Text('降噪')
                .textStyle(Theme.of(context).textTheme.labelMedium!)
                .padding(horizontal: 16.0, top: 24.0, bottom: 8.0),
            ValueListenableBuilder(
              valueListenable: client.noiseSuppressionLevelNotifier,
              builder: (context, level, child) => NoiseSuppressionLevel.values
                  .map(
                    (e) => RadioListTile(title: Text(names[e.index]), value: e),
                  )
                  .toList()
                  .toColumn()
                  .radioGroup(
                    groupValue: level,
                    onChanged: (value) {
                      client.noiseSuppressionLevelNotifier.value = value!;
                    },
                  ),
            ),
          ].toColumn().scrollable(
            controller: PrimaryScrollController.of(context),
            padding: EdgeInsets.only(bottom: 16.0),
          );
        },
      ),
    );
  }
}
