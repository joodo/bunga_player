import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/widgets/input_builder.dart';
import 'package:bunga_player/utils/extensions/string.dart';
import 'package:bunga_player/utils/models/file_extensions.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class DirectLinkTab extends StatefulWidget {
  const DirectLinkTab({super.key});

  @override
  State<DirectLinkTab> createState() => _DirectLinkTabState();
}

class _DirectLinkTabState extends State<DirectLinkTab> {
  bool inValidInput = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputBuilder(
      builder: (context, textEditingController, focusNode, child) =>
          [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: '视频链接',
                    hintText: '支持 B 站、m3u8 等链接',
                    errorText: inValidInput ? '不是有效 url' : null,
                  ),
                  controller: textEditingController,
                  focusNode: focusNode,
                ),
                [
                  ValueListenableBuilder(
                    valueListenable: textEditingController,
                    builder: (context, value, child) {
                      return FilledButton(
                        onPressed: value.text.isNotEmpty
                            ? () {
                                final urls = value.text.extractUrls();
                                if (urls.isEmpty) {
                                  setState(() {
                                    inValidInput = true;
                                  });
                                } else {
                                  Actions.invoke(
                                    context,
                                    SelectUrlIntent(Uri.parse(urls.first)),
                                  );
                                }
                              }
                            : null,
                        child: const Text(
                          '打开',
                        ).fontSize(theme.textTheme.titleMedium?.fontSize),
                      );
                    },
                  ),
                  child!.padding(left: 16.0),
                ].toRow(),
              ]
              .toColumn(
                crossAxisAlignment: .start,
                mainAxisAlignment: .center,
                separator: const SizedBox(height: 12.0),
              )
              .constrained(maxWidth: 500)
              .padding(bottom: 56.0),
      onFocusGot: (controller) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      },
      child: ActionChip(
        label: const Text('打开本地文件'),
        avatar: const Icon(Icons.folder_open),
        onPressed: () async {
          final path = await LocalVideoDialog.exec();
          if (path != null) {
            if (!context.mounted) return;
            Actions.invoke(context, SelectUrlIntent(Uri.file(path)));
          }
        },
      ),
    ).center();
  }
}

class LocalVideoDialog {
  static const typeGroup = XTypeGroup(
    label: 'videos',
    uniformTypeIdentifiers: ['public.movie'],
    extensions: videoFileExtensions,
  );

  static Future<String?> exec() async {
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) return null;
    return file.path;
  }
}
