import 'package:bunga_player/providers/settings.dart';
import 'package:flutter/material.dart';

class HostDialog extends StatefulWidget {
  final String host;
  final String? error;
  final SettingProxy proxy;

  const HostDialog({
    super.key,
    required this.host,
    this.error,
    required this.proxy,
  });

  @override
  State<HostDialog> createState() => _HostDialogState();
}

class _HostDialogState extends State<HostDialog> {
  late TextEditingController _hostFieldController;
  late TextEditingController _proxyFieldController;

  @override
  void initState() {
    super.initState();
    _hostFieldController = TextEditingController(text: widget.host);
    _proxyFieldController = TextEditingController(text: widget.proxy.value);
  }

  @override
  void dispose() {
    _hostFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置服务器'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _hostFieldController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: '新的服务器地址',
              errorText: widget.host.isEmpty ? null : widget.error,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _proxyFieldController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '网络代理',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            final newProxy = _proxyFieldController.text;
            widget.proxy.value = newProxy.isEmpty ? null : newProxy;
            Navigator.pop(context, _hostFieldController.text);
          },
          child: const Text('重试'),
        ),
      ],
    );
  }
}
