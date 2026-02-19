import 'package:bunga_player/play/global_business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/screens/widgets/input_builder.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/network/global_business.dart';

class AdvancedSettings extends StatelessWidget with SettingsTab {
  @override
  final label = '高级';
  @override
  final icon = Icons.tune_outlined;
  @override
  final selectedIcon = Icons.tune;

  const AdvancedSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      const Text('网络').sectionTitle(),
      [
            Consumer3<BungaServerInfo?, FetchingBungaClient, BungaHostAddress>(
              builder: (context, clientInfo, fetching, hostAddress, child) =>
                  InputBuilder(
                    initValue: hostAddress.value,
                    builder:
                        (
                          context,
                          textEditingController,
                          focusNode,
                          child,
                        ) => TextField(
                          decoration: InputDecoration(
                            labelText: 'Bunga 服务器',
                            errorText: clientInfo == null && !fetching.value
                                ? hostAddress.value.isEmpty
                                      ? '设置服务器地址'
                                      : '无法连接'
                                : null,
                            border: const OutlineInputBorder(),
                            suffixIcon: ValueListenableBuilder(
                              valueListenable: textEditingController,
                              builder: (context, hostFieldValue, child) =>
                                  fetching.value
                                  ? const LoadingButtonIcon()
                                        .center()
                                        .constrained(width: 36.0, height: 36.0)
                                  : hostFieldValue.text == hostAddress.value &&
                                        clientInfo != null
                                  ? const Icon(Icons.check)
                                        .iconSize(IconTheme.of(context).size!)
                                        .iconColor(Colors.greenAccent)
                                  : TextButton(
                                      onPressed: Actions.handler(
                                        context,
                                        ConnectToHostIntent(
                                          hostFieldValue.text,
                                        ),
                                      ),
                                      child: const Text('连接'),
                                    ),
                            ).padding(right: 8.0),
                          ),
                          enabled: !fetching.value,
                          controller: textEditingController,
                        ),
                  ),
            ),
            InputBuilder(
              initValue: context.read<SettingProxy>().value,
              builder: (context, textEditingController, focusNode, child) =>
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '代理',
                      helperText: '格式示例：127.0.0.1:7890，留空表示不使用代理',
                      border: OutlineInputBorder(),
                    ),
                    controller: textEditingController,
                    focusNode: focusNode,
                  ),
              onFocusLose: (controller) {
                final newProxy = controller.value.text;
                context.read<SettingProxy>().value = newProxy.isEmpty
                    ? null
                    : newProxy;
              },
            ),
          ]
          .toColumn(separator: const SizedBox(height: 16.0))
          .padding(all: 16.0)
          .sectionContainer(),
      const Text('播放器内核').sectionTitle(),
      const _PlayerBackedRadios().sectionContainer(),
    ].toColumn(crossAxisAlignment: .start);
  }
}

class _PlayerBackedRadios extends StatefulWidget {
  const _PlayerBackedRadios();

  @override
  State<_PlayerBackedRadios> createState() => _PlayerBackedRadiosState();
}

class _PlayerBackedRadiosState extends State<_PlayerBackedRadios> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final backendNotifier = context.read<PlayerBackendNotifier>();
    return ValueListenableBuilder(
      valueListenable: backendNotifier,
      builder: (context, backend, child) {
        return RadioGroup<PlayerBackend>(
          onChanged: (value) async {
            setState(() {
              _isBusy = true;
            });
            await backendNotifier.switchTo(value!);
            // Await for some async init method in play service constructor
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _isBusy = false;
            });
          },
          groupValue: backend,
          child: [
            RadioListTile<PlayerBackend>(
              title: Text('Media Kit'),
              subtitle: Text('支持更多视频格式，以及字幕、画面均衡等高级功能。'),
              value: .mediaKit,
              enabled: !_isBusy,
            ),
            RadioListTile<PlayerBackend>(
              title: Text('Agora Media Player'),
              subtitle: Text('在语音通话时，有效减少外放带来的回音。同时，耗费系统资源少，对老旧设备更友好。'),
              value: .agoraMediaPlayer,
              enabled: !_isBusy,
            ),
          ].toColumn(),
        );
      },
    );
  }
}
