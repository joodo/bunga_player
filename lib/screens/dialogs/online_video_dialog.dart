import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/clients/bunga.dart';
import 'package:bunga_player/providers/clients/online_video.dart';
import 'package:bunga_player/screens/widgets/hyper_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnlineVideoDialog extends StatefulWidget {
  const OnlineVideoDialog({super.key});
  @override
  State<OnlineVideoDialog> createState() => _OnlineVideoDialogState();
}

class _OnlineVideoDialogState extends State<OnlineVideoDialog> {
  bool _pending = false;
  bool _failed = false;
  Iterable<String>? _epNames;
  int? _selectedEpIndex;

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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
                text: '支持网站： ',
                children: [
                  createHyperText(
                    context,
                    text: '哔哩哔哩',
                    url: 'https://www.bilibili.com/',
                  ),
                  const TextSpan(text: '  '),
                  for (final site
                      in context.read<OnlineVideoClient>().supportSites ?? [])
                    TextSpan(
                      children: [
                        createHyperText(
                          context,
                          text: site.name,
                          url: site.url,
                        ),
                        const TextSpan(text: '  '),
                      ],
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
              onChanged: (value) {
                setState(() {
                  _selectedEpIndex = null;
                  _epNames = null;
                });
              },
              onSubmitted: (text) {
                if (text.isNotEmpty) _onSubmitUrl();
              },
            ),
            Visibility(
              visible: _epNames != null,
              child: SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: DropdownButton<int>(
                    value: _selectedEpIndex,
                    isExpanded: true,
                    elevation: 16,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedEpIndex = value!;
                      });
                    },
                    items: _epNames?.indexed
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.$1,
                            child: Text(entry.$2),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
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
            child: _pending
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(),
                  )
                : const Text('解析'),
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
      var uri = Uri.parse(_textController.text);
      if (_selectedEpIndex != null) {
        uri = uri.replace(queryParameters: {'ep': _selectedEpIndex.toString()});
      }

      final entry =
          await context.read<OnlineVideoClient>().getEntryFromUri(uri);

      // prefetch in case site not support
      if (!mounted) return;
      if (entry is M3u8Entry) await entry.fetch(context.read);

      if (!mounted) return;
      Navigator.pop<VideoEntry>(context, entry);
    } catch (e) {
      if (e is NeedEpisodeIndexException) {
        _epNames = e.episodeNames;
        _selectedEpIndex = 0;
      } else {
        _failed = true;
        rethrow;
      }
    } finally {
      setState(() {
        _pending = false;
      });
    }
  }
}
