import 'package:bunga_player/providers/settings.dart';
import 'package:flutter/material.dart';

class HostDialog extends StatefulWidget {
  final String? host;
  final String? error;
  final SettingProxy proxy;

  const HostDialog({super.key, this.host, this.error, required this.proxy});

  @override
  State<HostDialog> createState() => _HostDialogState();
}

class _HostDialogState extends State<HostDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.host);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.error),
      title: const Text('服务器失效'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.error != null) SelectableText(widget.error!),
          if (widget.error != null) const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '新的服务器地址',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        if (widget.proxy.value?.isNotEmpty ?? false)
          TextButton(
            onPressed: () {
              widget.proxy.value = null;
              Navigator.pop(context, _controller.text);
            },
            child: const Text('关闭代理'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('重试'),
        ),
      ],
    );
  }
}
