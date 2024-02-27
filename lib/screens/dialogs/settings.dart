import 'package:bunga_player/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatefulWidget {
  final Locator read;
  const SettingsDialog(this.read, {super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _proxyFieldController = TextEditingController();
  final _proxyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    final proxy = widget.read<SettingProxy>();

    _proxyFieldController.text = proxy.value ?? '';
    _proxyFocusNode.addListener(() {
      if (!_proxyFocusNode.hasFocus) {
        if (_proxyFieldController.text.isEmpty) {
          proxy.value = null;
        } else {
          proxy.value = _proxyFieldController.text;
        }
      }
    });
  }

  @override
  void dispose() {
    _proxyFieldController.dispose();
    _proxyFocusNode.dispose();
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
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '网络代理'),
                controller: _proxyFieldController,
                focusNode: _proxyFocusNode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
