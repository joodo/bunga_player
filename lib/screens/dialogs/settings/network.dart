import 'package:bunga_player/screens/widgets/input_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/bunga_server/actions.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/network/providers.dart';

class NetworkSettings extends StatelessWidget with SettingsTab {
  @override
  final label = '网络';
  @override
  final icon = Icons.lan_outlined;
  @override
  final selectedIcon = Icons.lan;

  const NetworkSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      const Text('服务器').sectionTitle(),
      Consumer3<BungaClientInfo?, FetchingBungaClient, BungaHostAddress>(
        builder: (context, clientInfo, fetching, hostAddress, child) =>
            InputBuilder(
          initValue: hostAddress.value,
          builder: (context, textEditingController, focusNode, child) =>
              TextField(
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
                builder: (context, hostFieldValue, child) => fetching.value
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
                              ConnectToHostIntent(hostFieldValue.text),
                            ),
                            child: const Text('连接'),
                          ),
              ).padding(right: 8.0),
            ),
            enabled: !fetching.value,
            controller: textEditingController,
          ),
        ),
      ).padding(all: 16.0).sectionContainer(),
      const Text('代理').sectionTitle(),
      InputBuilder(
        initValue: context.read<SettingProxy>().value,
        builder: (context, textEditingController, focusNode, child) =>
            TextField(
          decoration: const InputDecoration(
            labelText: '网络代理',
            border: OutlineInputBorder(),
          ),
          controller: textEditingController,
          focusNode: focusNode,
        ).padding(all: 16.0).sectionContainer(),
        onFocusLose: (controller) {
          final newProxy = controller.value.text;
          context.read<SettingProxy>().value =
              newProxy.isEmpty ? null : newProxy;
        },
      ),
    ].toColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
