import 'package:bunga_player/providers/clients/bunga.dart';
import 'package:bunga_player/providers/clients/clients.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/player_section/danmaku_player.dart';
import 'package:bunga_player/screens/widgets/widget_in_button.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/slider_dense_track_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nested/nested.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (value) => setState(() {
                _selectedIndex = value;
              }),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.lan_outlined),
                  selectedIcon: Icon(Icons.lan),
                  label: Text('网络'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.chat_outlined),
                  selectedIcon: Icon(Icons.chat),
                  label: Text('互动'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: Text('关于'),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      _NetworkSettings(),
                      _ReactionSettings(),
                      _AboutSetting(),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: FilledButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text('确定'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _NetworkSettings extends StatefulWidget {
  const _NetworkSettings();

  @override
  State<_NetworkSettings> createState() => _NetworkSettingsState();
}

class _NetworkSettingsState extends State<_NetworkSettings> {
  final _proxyFieldController = TextEditingController();
  final _hostFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _proxyFieldController.text = context.read<SettingProxy>().value ?? '';
    _hostFieldController.text = context.read<SettingBungaHost>().value;
  }

  @override
  void dispose() {
    _proxyFieldController.dispose();
    _hostFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionText('服务器'),
          _SectionContainer(
            child: Consumer3<BungaClient?, PendingBungaHost, SettingBungaHost>(
              builder: (context, client, pending, host, child) => TextField(
                decoration: InputDecoration(
                  labelText: 'Bunga 服务器',
                  errorText: client == null && !pending.value
                      ? host.value.isEmpty
                          ? '设置服务器地址'
                          : '无法连接'
                      : null,
                  border: const OutlineInputBorder(),
                  suffix: ValueListenableBuilder(
                    valueListenable: _hostFieldController,
                    builder: (context, hostFieldValue, child) => TextButton(
                      onPressed:
                          pending.value || hostFieldValue.text == client?.host
                              ? null
                              : _connectToHost,
                      child: pending.value
                          ? createIndicatorInButton(context)
                          : hostFieldValue.text == client?.host
                              ? createIconInButton(
                                  context,
                                  Icons.check,
                                  color: Colors.greenAccent,
                                )
                              : const Text('连接'),
                    ),
                  ),
                ),
                enabled: !pending.value,
                controller: _hostFieldController,
              ),
            ),
          ),
          const _SectionText('代理'),
          _SectionContainer(
            child: TextField(
              decoration: const InputDecoration(
                labelText: '网络代理',
                border: OutlineInputBorder(),
              ),
              controller: _proxyFieldController,
              onChanged: (value) => context.read<SettingProxy>().value =
                  value.isEmpty ? null : value,
            ),
          ),
        ],
      ),
    );
  }

  void _connectToHost() async {
    final newHost = _hostFieldController.text;
    final bungaClient = BungaClient(newHost);
    final clientId = context.read<SettingClientId>().value;

    final clientNotifier = context.read<BungaClientNotifier>();
    final pendingNotifier = context.read<PendingBungaHost>();
    final hostNotifier = context.read<SettingBungaHost>();

    try {
      pendingNotifier.value = true;
      clientNotifier.value = null;

      await bungaClient.register(clientId);
      clientNotifier.value = bungaClient;
      hostNotifier.value = newHost;
    } catch (e) {
      logger.e('Create Bunga client failed: $e');
    } finally {
      pendingNotifier.value = false;
    }
  }
}

class _ReactionSettings extends StatefulWidget {
  const _ReactionSettings();

  @override
  State<_ReactionSettings> createState() => _ReactionSettingsState();
}

class _ReactionSettingsState extends State<_ReactionSettings> {
  late final _hueProvider = context.read<SettingColorHue>();
  late int _hue = _hueProvider.value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionText('个性化'),
          _SectionContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('弹幕颜色'),
                _ColorSlider(
                  value: _hue,
                  onChanged: (value) => setState(() {
                    _hue = value;
                  }),
                ),
                DanmakuText(
                  text: '测试弹幕样式',
                  hue: _hue,
                ),
              ],
            ),
          ),
          const _SectionText('行为'),
          Consumer<SettingAutoJoinChannel>(
            builder: (context, autoJoinNotifier, child) => SwitchListTile(
              title: const Text('打开视频后自动加入房间'),
              value: autoJoinNotifier.value,
              onChanged: (value) => autoJoinNotifier.value = value,
            ),
          ),
        ],
      ),
    );
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

  final _colors = [
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

  _ColorSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: _colors),
        ),
        height: 15,
        child: SliderTheme(
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
        ),
      ),
    );
  }
}

class _AboutSetting extends StatelessWidget {
  const _AboutSetting();
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          SvgPicture.asset(
            'assets/images/icon.svg',
            width: 96,
          ),
          const SizedBox(height: 16),
          Text(
            getIt<PackageInfo>().appName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('版本: ${getIt<PackageInfo>().version}'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: getIt<PackageInfo>().appName,
            ),
            child: const Text('查看许可'),
          ),
        ],
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _SectionContainer extends SingleChildStatelessWidget {
  const _SectionContainer({super.child});
  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: child!,
        ),
      ),
    );
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
