import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/services/online_video.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OnlineVideoDialog extends StatefulWidget {
  const OnlineVideoDialog({super.key});
  @override
  State<OnlineVideoDialog> createState() => _OnlineVideoDialogState();
}

class _OnlineVideoDialogState extends State<OnlineVideoDialog> {
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
      title: const Text('打开在线视频'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: '支持网站：',
                children: [
                  TextSpan(
                    text: ' 哔哩哔哩 ',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => launchUrlString('https://www.bilibili.com/'),
                  ),
                  for (final site in getIt<OnlineVideoService>().supportSites)
                    TextSpan(
                      text: ' ${site.name} ',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(site.url),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              focusNode: _focusNode,
              controller: _textController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '视频链接',
                errorText: _failed ? '解析失败' : null,
              ),
              onSubmitted: (text) {
                if (text.isNotEmpty) _onSubmitUrl();
              },
            ),
          ],
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
            onPressed: _pending || value.text.isEmpty ? null : _onSubmitUrl,
            child:
                _pending ? const CircularProgressIndicator() : const Text('解析'),
          ),
        ),
      ],
    );
  }

  void _onSubmitUrl() async {
    setState(() {
      _failed = false;
      _pending = true;
    });

    try {
      final uri = Uri.parse(_textController.text);
      final entry = await getIt<OnlineVideoService>().getEntryFromUri(uri);
      if (mounted) Navigator.pop<VideoEntry>(context, entry);
    } finally {
      setState(() {
        _failed = true;
        _pending = false;
      });
    }
  }
}
