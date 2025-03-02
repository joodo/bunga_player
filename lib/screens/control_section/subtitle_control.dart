import 'package:bunga_player/play/actions.dart';
import 'package:bunga_player/play_sync/actions.dart';
import 'package:bunga_player/mocks/slider.dart' as mock;
import 'package:bunga_player/mocks/dropdown.dart' as mock;
import 'package:bunga_player/mocks/tooltip.dart' as mock;
import 'package:bunga_player/play/models/track.dart';
import 'package:bunga_player/play/providers.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/screens/widgets/loading_button_icon.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../widgets/divider.dart';
import 'channel_required_wrap.dart';
import 'dropdown.dart';

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
  final _controllers = {
    SubtitleControlUIState.delay: _SubtitleController(
      labelText: '延迟',
      iconData: Icons.timer,
      valueProvider: (context) =>
          context.select<PlaySubDelay, double>((provider) => provider.value),
      minValue: -10.0,
      maxValue: 10.0,
      unit: 's',
      setter: (value, BuildContext context) => Actions.invoke(
        context,
        SetSubDelayIntent(value),
      ),
      resetter: (context) => Actions.invoke(
        context,
        const SetSubDelayIntent(),
      ),
    ),
    SubtitleControlUIState.size: _SubtitleController(
      labelText: '大小',
      iconData: Icons.format_size,
      valueProvider: (context) => context
          .select<PlaySubSize, double>((provider) => provider.value.toDouble()),
      minValue: 15.0,
      maxValue: 65.0,
      unit: 'px',
      setter: (value, BuildContext context) => Actions.invoke(
        context,
        SetSubSizeIntent(value.toInt()),
      ),
      resetter: (context) => Actions.invoke(
        context,
        const SetSubSizeIntent(),
      ),
    ),
    SubtitleControlUIState.position: _SubtitleController(
      labelText: '高度',
      iconData: Icons.height,
      valueProvider: (context) => context
          .select<PlaySubPos, double>((provider) => provider.value.toDouble()),
      minValue: -10.0,
      maxValue: 100.0,
      unit: '%',
      setter: (value, BuildContext context) => Actions.invoke(
        context,
        SetSubPosIntent(value.toInt()),
      ),
      resetter: (context) => Actions.invoke(
        context,
        const SetSubPosIntent(),
      ),
    ),
  };

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final subController = _controllers[_subtitleUIState]!;
    _textController.text =
        subController.valueProvider(context).toStringAsFixed(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fold = constraints.maxWidth < 860;
        return Row(
          children: [
            const SizedBox(width: 8),
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: Navigator.of(context).pop,
            ),
            const SizedBox(width: 8),
/* TODO: onprogress
            // Subtitle dropbox
            Consumer3<PlaySubtitleTracks, PlaySubtitleTrackID,
                ChannelSubtitles>(
              builder:
                  (context, tracks, currentTrackID, channelSubtitles, child) {
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

                final localTracks = tracks.value.where((track) {
                  if (track.uri == null) return false;

                  if (!track.uri!.startsWith('http')) return true;

                  final channelIds = channelSubtitles.value.values
                      .map((e) => e.track?.id)
                      .toList();
                  if (!channelIds.contains(track.id)) return true;

                  return false;
                });
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

                final localSubPath = localTracks
                    .firstWhereOrNull(
                        (track) => track.id == currentTrackID.value)
                    ?.uri!;
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
                      _ShareButton(path: localSubPath),
                    ],
                  ),
                );
              },
            ),
            const ControlDivider(),
            const SizedBox(width: 8),
*/
            // Subtitle adjust
            SegmentedButton<SubtitleControlUIState>(
              showSelectedIcon: false,
              segments: _controllers.entries
                  .map((entry) => ButtonSegment<SubtitleControlUIState>(
                        value: entry.key,
                        label: fold ? null : Text(entry.value.labelText),
                        icon: Icon(entry.value.iconData),
                      ))
                  .toList(),
              selected: <SubtitleControlUIState>{_subtitleUIState},
              onSelectionChanged: (Set<SubtitleControlUIState> newSelection) {
                setState(() {
                  _subtitleUIState = newSelection.first;
                });
              },
            ),
            const SizedBox(width: 16),

            if (fold) Text(subController.labelText),
            if (fold) const SizedBox(width: 8),

            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 200,
                      child: mock.MySlider(
                        value: subController.valueProvider(context).clamp(
                              subController.minValue,
                              subController.maxValue,
                            ),
                        min: subController.minValue,
                        max: subController.maxValue,
                        onChanged: (value) =>
                            subController.setter(value, context),
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
                      onEditingComplete: () => subController.setter(
                        double.parse(_textController.text),
                        context,
                      ),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        border: const OutlineInputBorder(),
                        suffix: Text(subController.unit),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.restart_alt),
                    iconSize: 16.0,
                    onPressed: () => subController.resetter(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  final _textController = TextEditingController();

  String _titleFromTrack(SubtitleTrack track) =>
      '${track.title ?? ''}${track.language != null ? ' (${track.language})' : ''}';
}

class _ShareButton extends StatefulWidget {
  final String? path;
  const _ShareButton({required this.path});
  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final iconButton = ChannelRequiredWrap(
      builder: (context, action, child) => IconButton(
        icon: !_uploading
            ? const Icon(Icons.ios_share)
            : const LoadingButtonIcon(),
        onPressed: action,
      ),
      action: !_uploading
          ? () async {
              setState(() => _uploading = true);

              final progresses = Actions.invoke(
                context,
                ShareSubtitleIntent(widget.path!),
              ) as Stream<RequestProgress>;
              await progresses.last;

              if (!mounted) return;
              setState(() => _uploading = false);
            }
          : null,
    );

    final animatedContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: widget.path != null ? 40 : 0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        scale: widget.path != null ? 1 : 0,
        child: iconButton,
      ),
    );

    return mock.Tooltip(
      message: '分享字幕',
      rootOverlay: true,
      child: animatedContainer,
    );
  }
}

class _SubtitleController {
  final String labelText;
  final IconData iconData;
  final double Function(BuildContext context) valueProvider;
  final double minValue, maxValue;
  final String unit;
  final void Function(double value, BuildContext context) setter;
  final void Function(BuildContext context) resetter;

  _SubtitleController({
    required this.labelText,
    required this.iconData,
    required this.valueProvider,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.setter,
    required this.resetter,
  });
}
