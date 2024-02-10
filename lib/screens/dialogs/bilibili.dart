import 'package:bunga_player/models/playing/video_entry.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';

class BiliDialog extends StatefulWidget {
  const BiliDialog({super.key});
  @override
  State<BiliDialog> createState() => _BiliDialogState();
}

class _BiliDialogState extends State<BiliDialog> {
  bool _pending = false;
  bool _failed = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textController.text.length,
        );
      }
    });
    super.initState();
  }

  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      title: const Text('打开 Bilibili 视频'),
      content: SizedBox(
        width: 400,
        child: TextField(
          focusNode: _focusNode,
          controller: _textController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: '视频链接',
            errorText: _failed ? '解析失败' : null,
          ),
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
            onPressed: _pending || value.text.isEmpty ? null : _onSubmitBiliUrl,
            child:
                _pending ? const CircularProgressIndicator() : const Text('解析'),
          ),
        ),
      ],
    );
  }

  void _onSubmitBiliUrl() async {
    setState(() {
      _failed = false;
      _pending = true;
    });

    try {
      final uri = Uri.parse(_textController.text);
      final entry = await getService<Bilibili>().getEntryFromUri(uri);
      if (context.mounted) Navigator.pop<VideoEntry>(context, entry);
    } finally {
      setState(() {
        _failed = true;
        _pending = false;
      });
    }
  }
}
