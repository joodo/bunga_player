import 'package:flutter/material.dart';

class BiliDialog extends StatefulWidget {
  const BiliDialog({super.key});
  @override
  State<BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<BiliDialog> {
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      title: const Text('打开 Bilibili 视频'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: '视频链接',
          ),
          onTap: () {
            _textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _textController.text.length,
            );
          },
          onSubmitted: (text) {
            if (text.isNotEmpty) _onSubmitBiliUrl();
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ValueListenableBuilder(
          valueListenable: _textController,
          builder: (context, value, child) => TextButton(
            onPressed: value.text.isEmpty ? null : _onSubmitBiliUrl,
            child: const Text('解析'),
          ),
        ),
      ],
    );
  }

  void _onSubmitBiliUrl() {
    Navigator.pop(context, _textController.text);
  }
}
