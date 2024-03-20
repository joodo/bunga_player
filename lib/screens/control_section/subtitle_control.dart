import 'package:bunga_player/actions/play.dart';
import 'package:bunga_player/actions/video_playing.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:bunga_player/mocks/tooltip.dart' as mock;
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/video_playing.dart';
import 'package:bunga_player/screens/control_section/dropdown.dart';
import 'package:bunga_player/providers/clients/chat.dart';
import 'package:bunga_player/services/player.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum SubtitleControlUIState {
  delay,
  size,
  position,
}

class SubtitleControl extends StatefulWidget {
  const SubtitleControl({super.key});

  @override
  State<SubtitleControl> createState() => _SubtitleControlState();
}

class _SubtitleControlState extends State<SubtitleControl> {
  SubtitleControlUIState _subtitleUIState = SubtitleControlUIState.delay;

  bool _loading = false;
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final value = <SubtitleControlUIState, double>{
      SubtitleControlUIState.delay:
          context.select<PlaySubDelay, double>((provider) => provider.value),
      SubtitleControlUIState.size: context
          .select<PlaySubSize, double>((provider) => provider.value.toDouble()),
      SubtitleControlUIState.position: context
          .select<PlaySubPos, double>((provider) => provider.value.toDouble()),
    }[_subtitleUIState]!;
    final minValue = <SubtitleControlUIState, double>{
      SubtitleControlUIState.delay: -10.0,
      SubtitleControlUIState.size: 15.0,
      SubtitleControlUIState.position: -10.0,
    }[_subtitleUIState]!;
    final maxValue = <SubtitleControlUIState, double>{
      SubtitleControlUIState.delay: 10.0,
      SubtitleControlUIState.size: 65.0,
      SubtitleControlUIState.position: 100.0,
    }[_subtitleUIState]!;
    final surfix = <SubtitleControlUIState, String>{
      SubtitleControlUIState.delay: 's',
      SubtitleControlUIState.size: 'px',
      SubtitleControlUIState.position: '%',
    }[_subtitleUIState]!;
    final setter = <SubtitleControlUIState, void Function(double)>{
      SubtitleControlUIState.delay: (double value) => Actions.invoke(
            context,
            SetSubDelayIntent(value),
          ),
      SubtitleControlUIState.size: (double value) => Actions.invoke(
            context,
            SetSubSizeIntent(value.toInt()),
          ),
      SubtitleControlUIState.position: (double value) => Actions.invoke(
            context,
            SetSubPosIntent(value.toInt()),
          ),
    }[_subtitleUIState];
    final resetter = <SubtitleControlUIState, void Function()>{
      SubtitleControlUIState.delay: () => Actions.invoke(
            context,
            const SetSubDelayIntent(),
          ),
      SubtitleControlUIState.size: () => Actions.invoke(
            context,
            const SetSubSizeIntent(),
          ),
      SubtitleControlUIState.position: () => Actions.invoke(
            context,
            const SetSubPosIntent(),
          ),
    }[_subtitleUIState];

    _textController.text = value.toStringAsFixed(1);

    return Row(
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
        const SizedBox(width: 8),

        // Subtitle dropbox
        Consumer3<PlaySubtitleTracks, PlaySubtitleTrackID, ChannelSubtitles>(
          builder: (context, tracks, currentTrackID, channelSubtitles, child) {
            final internalEntries =
                tracks.value.where((track) => !track.isExternal).map(
                      (track) => mock.DropdownMenuItem<String>(
                        value: track.id,
                        child: Text(
                          () {
                            if (track.id == 'auto') return '默认';
                            if (track.id == 'no') return '无字幕';

                            return _titleFromTrack(track);
                          }(),
                        ),
                      ),
                    );

            final sharedEntries = channelSubtitles.value.values.map(
              (channelSubtitle) {
                final trackId = channelSubtitle.track?.id;
                return mock.DropdownMenuItem<String>(
                  value: trackId,
                  onTap: trackId == null
                      ? () async {
                          setState(() => _loading = true);
                          final response = Actions.invoke(
                            context,
                            FetchChannelSubtitleIntent(channelSubtitle),
                          ) as Future;
                          await response;

                          if (!context.mounted) return;
                          Actions.invoke(context,
                              SetSubtitleIntent(channelSubtitle.track!.id));
                          setState(() => _loading = false);
                        }
                      : null,
                  child: Text(
                      '${channelSubtitle.sharer.name} 分享：${channelSubtitle.title}'),
                );
              },
            );

            final localTracks = tracks.value
                .where((track) => !(track.uri?.startsWith('http') ?? true));
            final localEntries = localTracks.map(
              (track) => mock.DropdownMenuItem<String>(
                value: track.id,
                child: Text(_titleFromTrack(track)),
              ),
            );

            final openSubtitleEntry = mock.DropdownMenuItem<String>(
              child: const Text('打开字幕...'),
              onTap: () async {
                final file = await openFile();
                if (!context.mounted || file == null) return;

                // load subtitle file from local
                setState(() => _loading = true);
                final response = Actions.invoke(
                  context,
                  LoadLocalSubtitleIntent(file.path),
                ) as Future<SubtitleTrack?>;
                final track = await response;

                if (!context.mounted) return;
                if (track != null) {
                  Actions.invoke(
                    context,
                    SetSubtitleIntent(track.id),
                  );
                }
                setState(() => _loading = false);
              },
            );

            bool showShareButton = !_loading &&
                localTracks.any((track) => track.id == currentTrackID.value);
            return SizedBox(
              width: 250,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ControlDropdown(
                        enabled: !_loading,
                        items: <mock.DropdownMenuItem<String>>[
                          ...internalEntries,
                          const mock.DropdownMenuDivider<String>(),
                          ...sharedEntries,
                          if (sharedEntries.isNotEmpty)
                            const mock.DropdownMenuDivider<String>(),
                          ...localEntries,
                          if (localEntries.isNotEmpty)
                            const mock.DropdownMenuDivider<String>(),
                          openSubtitleEntry,
                        ],
                        value: currentTrackID.value,
                        onChanged: (subtitleID) {
                          if (subtitleID != null) {
                            Actions.invoke(
                                context, SetSubtitleIntent(subtitleID));
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  mock.Tooltip(
                    message: '分享字幕',
                    rootOverlay: true,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      width: showShareButton ? 40 : 0,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        scale: showShareButton ? 1 : 0,
                        child: IconButton(
                          icon: !_uploading
                              ? const Icon(Icons.ios_share)
                              : SizedBox.square(
                                  dimension: IconTheme.of(context).size,
                                  child: const CircularProgressIndicator(),
                                ),
                          onPressed: !_uploading &&
                                  Actions.maybeFind(
                                        context,
                                        intent: const ShareSubtitleIntent(''),
                                      ) !=
                                      null
                              ? () async {
                                  setState(() => _uploading = true);

                                  final progresses = Actions.invoke(
                                    context,
                                    ShareSubtitleIntent(localTracks
                                        .firstWhere((track) =>
                                            track.id == currentTrackID.value)
                                        .uri!),
                                  ) as Stream<UploadProgress>;
                                  await progresses.last;

                                  if (!mounted) return;
                                  setState(() => _uploading = false);
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const VerticalDivider(indent: 8, endIndent: 8),
        const SizedBox(width: 8),

        // Subtitle adjust
        SegmentedButton<SubtitleControlUIState>(
          showSelectedIcon: false,
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
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: SizedBox(
                  width: 200,
                  child: mock.MySlider(
                    value: value.clamp(minValue, maxValue),
                    max: maxValue,
                    min: minValue,
                    onChanged: setter,
                    focusNode: FocusNode(canRequestFocus: false),
                    useRootOverlay: true,
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
                  controller: _textController,
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
                    _textController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _textController.text.length,
                    );
                  },
                  onEditingComplete: () => setter?.call(
                    double.parse(_textController.text),
                  ),
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
                onPressed: resetter,
              ),
            ],
          ),
        ),
      ],
    );
  }

  final _textController = TextEditingController();

  String _titleFromTrack(SubtitleTrack track) =>
      '${track.title ?? ''}${track.language != null ? ' (${track.language})' : ''}';
}
