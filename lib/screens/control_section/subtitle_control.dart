import 'package:bunga_player/singletons/video_controller.dart';
import 'package:bunga_player/screens/control_section/dropdown.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

enum SubtitleControlUIState {
  delay,
  size,
  position,
}

class SubtitleControl extends StatefulWidget {
  final VoidCallback onBackPressed;

  const SubtitleControl({
    super.key,
    required this.onBackPressed,
  });

  @override
  State<SubtitleControl> createState() => _SubtitleControlState();
}

class _SubtitleControlState extends State<SubtitleControl> {
  SubtitleControlUIState _subtitleUIState = SubtitleControlUIState.delay;

  @override
  Widget build(BuildContext context) {
    final listenable = {
      SubtitleControlUIState.delay: VideoController().subDelay,
      SubtitleControlUIState.size: VideoController().subSize,
      SubtitleControlUIState.position: VideoController().subPosition,
    }[_subtitleUIState]!;
    final minValue = {
      SubtitleControlUIState.delay: -10.0,
      SubtitleControlUIState.size: 20.0,
      SubtitleControlUIState.position: 0.0,
    }[_subtitleUIState]!;
    final maxValue = {
      SubtitleControlUIState.delay: 10.0,
      SubtitleControlUIState.size: 70.0,
      SubtitleControlUIState.position: 110.0,
    }[_subtitleUIState]!;
    final surfix = {
      SubtitleControlUIState.delay: 's',
      SubtitleControlUIState.size: 'px',
      SubtitleControlUIState.position: '%',
    }[_subtitleUIState]!;

    return Row(
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
        const SizedBox(width: 8),

        // Subtitle dropbox
        MultiValueListenableBuilder(
          valueListenables: [
            VideoController().track,
            VideoController().tracks,
          ],
          builder: (context, values, child) {
            var subtitleTracks = (values[1] as Tracks?)?.subtitle;

            return SizedBox(
              width: 200,
              height: 36,
              child: ControlDropdown(
                items: [
                  ...subtitleTracks?.map((e) => DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(() {
                              if (e.id == 'auto') return '默认';
                              if (e.id == 'no') return '无字幕';

                              String text = '[${e.id}]';
                              if (e.title != null) {
                                text += ' ${e.title}';
                              }
                              if (e.language != null) {
                                text += ' (${e.language})';
                              }
                              return text;
                            }()),
                          )) ??
                      [],
                  const DropdownMenuItem<String>(
                    value: 'OPEN',
                    child: Text('打开字幕……'),
                  ),
                ],
                value: values[0]?.subtitle.id,
                onChanged: (subtitleID) async {
                  if (subtitleID != 'OPEN') {
                    return VideoController().setSubtitleTrack(subtitleID);
                  }

                  final file = await openFile();
                  if (file != null) {
                    VideoController().addSubtitleTrack(file.path);
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(width: 16),

        // Subtitle adjust
        SegmentedButton<SubtitleControlUIState>(
          segments: const [
            ButtonSegment<SubtitleControlUIState>(
                value: SubtitleControlUIState.delay,
                label: Text('延迟'),
                icon: Icon(Icons.timer)),
            ButtonSegment<SubtitleControlUIState>(
                value: SubtitleControlUIState.size,
                label: Text('大小'),
                icon: Icon(Icons.format_size)),
            ButtonSegment<SubtitleControlUIState>(
                value: SubtitleControlUIState.position,
                label: Text('位置'),
                icon: Icon(Icons.height)),
          ],
          selected: <SubtitleControlUIState>{_subtitleUIState},
          onSelectionChanged: (Set<SubtitleControlUIState> newSelection) {
            setState(() {
              _subtitleUIState = newSelection.first;
            });
          },
        ),
        const SizedBox(width: 16),
        ValueListenableBuilder<double>(
          valueListenable: listenable,
          builder: (context, value, child) {
            final textController =
                TextEditingController(text: value.toStringAsFixed(1));
            var child = Row(
              children: [
                Flexible(
                  child: SizedBox(
                    width: 200,
                    child: Slider(
                      value: value < minValue
                          ? minValue
                          : value > maxValue
                              ? maxValue
                              : value,
                      max: maxValue,
                      min: minValue,
                      onChanged: (value) => listenable.value = value,
                      focusNode: FocusNode(canRequestFocus: false),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 64,
                  height: 32,
                  child: TextField(
                    cursorHeight: 16,
                    style: Theme.of(context).textTheme.bodySmall,
                    controller: textController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.-]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final newValueText = newValue.text;
                        if (newValueText == "-" ||
                            newValueText == "-." ||
                            newValueText == ".") {
                          // Returning new value if text field contains only "." or "-." or ".".
                          return newValue;
                        } else if (newValueText.isNotEmpty) {
                          // If text filed not empty and value updated then trying to parse it as a double.
                          try {
                            double.parse(newValueText);
                            // Here double parsing succeeds so returning that new value.
                            return newValue;
                          } catch (e) {
                            // Here double parsing failed so returning that old value.
                            return oldValue;
                          }
                        } else {
                          // Returning new value if text field was empty.
                          return newValue;
                        }
                      }),
                    ],
                    onTap: () {
                      textController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: textController.text.length,
                      );
                    },
                    onEditingComplete: () =>
                        listenable.value = double.parse(textController.text),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      border: const OutlineInputBorder(),
                      suffix: Text(surfix),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  iconSize: 16.0,
                  onPressed: listenable.reset,
                ),
              ],
            );
            return Expanded(child: child);
          },
        ),
      ],
    );
  }
}
