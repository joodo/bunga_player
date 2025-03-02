import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/widgets/input_builder.dart';
import 'package:bunga_player/screens/widgets/slider_dense_track_shape.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class ReactionSettings extends StatefulWidget with SettingsTab {
  @override
  final label = '互动';
  @override
  final icon = Icons.chat_outlined;
  @override
  final selectedIcon = Icons.chat;

  const ReactionSettings({super.key});

  @override
  State<ReactionSettings> createState() => _ReactionSettingsState();
}

class _ReactionSettingsState extends State<ReactionSettings> {
  late final _nicknameNotifier = context.read<ClientNicknameNotifier>();
  late final _hueProvider = context.read<ClientColorHue>();
  late int _hue = _hueProvider.value;

  @override
  Widget build(BuildContext context) {
    return [
      const Text('个性化').sectionTitle(),
      InputBuilder(
        builder: (context, textEditingController, focusNode, child) =>
            TextField(
          decoration: const InputDecoration(
            labelText: '昵称',
            border: OutlineInputBorder(),
          ),
          controller: textEditingController,
          focusNode: focusNode,
        ),
        initValue: _nicknameNotifier.value,
        onFocusLose: (controller) => _nicknameNotifier.value = controller.text,
      ).padding(all: 16.0).sectionContainer(),
      [
        const Text('弹幕颜色'),
        _ColorSlider(
          value: _hue,
          onChanged: (value) => setState(() {
            _hue = value;
          }),
        ),
        DanmakuText(text: '测试弹幕样式', hue: _hue),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .padding(all: 16.0)
          .sectionContainer(),
      const Text('行为').sectionTitle(),
      Consumer<AutoJoinChannel>(
        builder: (context, autoJoinNotifier, child) => SwitchListTile(
          title: const Text('打开视频后自动加入房间'),
          value: autoJoinNotifier.value,
          onChanged: (value) => autoJoinNotifier.value = value,
        ),
      ).sectionContainer(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }

  @override
  void dispose() {
    Future.microtask(() => _hueProvider.value = _hue);
    super.dispose();
  }
}

class _ColorSlider extends StatelessWidget {
  final int value;
  final Function(int value) onChanged;

  static final _colors = [
    const Color.fromARGB(255, 255, 0, 0),
    const Color.fromARGB(255, 255, 128, 0),
    const Color.fromARGB(255, 255, 255, 0),
    const Color.fromARGB(255, 128, 255, 0),
    const Color.fromARGB(255, 0, 255, 0),
    const Color.fromARGB(255, 0, 255, 128),
    const Color.fromARGB(255, 0, 255, 255),
    const Color.fromARGB(255, 0, 128, 255),
    const Color.fromARGB(255, 0, 0, 255),
    const Color.fromARGB(255, 127, 0, 255),
    const Color.fromARGB(255, 255, 0, 255),
    const Color.fromARGB(255, 255, 0, 127),
    const Color.fromARGB(255, 255, 0, 0),
  ];

  const _ColorSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackShape: SliderDenseTrackShape(),
        trackHeight: 16,
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: Colors.transparent,
        showValueIndicator: ShowValueIndicator.never,
        thumbShape: _ColorSliderThumbShape(),
      ),
      child: Slider(
        min: 0,
        max: 360,
        value: value.toDouble(),
        onChanged: (value) => onChanged(value.toInt()),
      ),
    )
        .decorated(
          border: Border.all(
            width: 2,
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: _colors),
        )
        .constrained(height: 15.0)
        .padding(horizontal: 0, vertical: 16.0);
  }
}

class _ColorSliderThumbShape extends RoundSliderThumbShape {
  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = sliderTheme.thumbColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}
