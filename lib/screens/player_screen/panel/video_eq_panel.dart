import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/widgets/slider_item.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'panel.dart';

typedef TuneItem = ({
  IconData icon,
  String name,
  ValueNotifier<int> notifier,
});

class VideoEqPanel extends StatelessWidget implements Panel {
  const VideoEqPanel({super.key});

  @override
  final type = 'video_eq';

  static final tuneItems = <TuneItem>[
    (
      icon: Icons.brightness_4,
      name: '亮度',
      notifier: getIt<PlayService>().brightnessNotifier,
    ),
    (
      icon: Icons.contrast,
      name: '对比度',
      notifier: getIt<PlayService>().contrastNotifier,
    ),
    (
      icon: Icons.opacity,
      name: '饱和度',
      notifier: getIt<PlayService>().saturationNotifier,
    ),
    (
      icon: Icons.signal_cellular_0_bar,
      name: '伽玛',
      notifier: getIt<PlayService>().gammaNotifier,
    ),
    (
      icon: Icons.palette,
      name: '色相',
      notifier: getIt<PlayService>().hueNotifier,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PanelWidget(
      title: '画面均衡',
      child: [
        Consumer<PlayEqPresetNotifier>(
          builder: (context, notifier, child) {
            return DropdownMenu<BCSGHPreset?>(
              enableSearch: false,
              expandedInsets: const EdgeInsets.all(0),
              initialSelection: notifier.value,
              dropdownMenuEntries: [
                ...PlayEqPresetNotifier.presets
                    .map((preset) => DropdownMenuEntry(
                          label: preset.title,
                          value: preset,
                        )),
                const DropdownMenuEntry(
                  label: '自定义',
                  value: null,
                ),
              ],
              onSelected: (preset) {
                notifier.value = preset;
                if (preset == null) return;
                final player = getIt<PlayService>();
                player.brightnessNotifier.value = preset.value[0];
                player.contrastNotifier.value = preset.value[1];
                player.saturationNotifier.value = preset.value[2];
                player.gammaNotifier.value = preset.value[3];
                player.hueNotifier.value = preset.value[4];
              },
            ).padding(top: 16.0, bottom: 12.0);
          },
        ),
        ...tuneItems.map(
          (item) => SliderItem(
            icon: item.icon,
            title: item.name,
            slider: ValueListenableBuilder(
              valueListenable: item.notifier,
              builder: (context, value, child) => Slider(
                min: -1.0,
                max: 1.0,
                value: value / 100.0,
                label: value.toString(),
                onChanged: (value) {
                  context.read<PlayEqPresetNotifier>().value = null;
                  final percent = value * 100;
                  item.notifier.value = percent.toInt();
                },
              ),
            ),
          ).padding(vertical: 2.0),
        ),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .padding(horizontal: 16.0)
          .scrollable(padding: EdgeInsets.only(bottom: 16.0)),
    );
  }
}
