import 'package:bunga_player/providers/clients/bunga.dart';
import 'package:bunga_player/providers/clients/clients.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/widgets/widget_in_button.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _proxyFieldController = TextEditingController();
  final _hostFieldController = TextEditingController();
  final _githubFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _proxyFieldController.text = context.read<SettingProxy>().value ?? '';
    _hostFieldController.text = context.read<SettingBungaHost>().value;
    _githubFieldController.text = context.read<SettingGithubProxy>().value;
  }

  @override
  void dispose() {
    _proxyFieldController.dispose();
    _hostFieldController.dispose();
    _githubFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('设置'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 400,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '网络代理'),
                  controller: _proxyFieldController,
                  onChanged: (value) => context.read<SettingProxy>().value =
                      value.isEmpty ? null : value,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: '更新代理',
                    helperText: '用于更快地下载更新文件',
                  ),
                  controller: _githubFieldController,
                  onChanged: (value) =>
                      context.read<SettingGithubProxy>().value = value,
                ),
                const SizedBox(height: 8),
                Consumer3<BungaClient?, PendingBungaHost, SettingBungaHost>(
                  builder: (context, client, pending, host, child) => TextField(
                    decoration: InputDecoration(
                      labelText: 'Bunga 服务器',
                      errorText: client == null && !pending.value
                          ? host.value.isEmpty
                              ? '设置服务器地址'
                              : '无法连接'
                          : null,
                      suffix: ValueListenableBuilder(
                        valueListenable: _hostFieldController,
                        builder: (context, hostFieldValue, child) => TextButton(
                          onPressed: pending.value ||
                                  hostFieldValue.text == client?.host
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
                )
              ],
            ),
          ),
        ),
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
