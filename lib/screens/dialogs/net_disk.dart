import 'dart:async';

import 'package:bunga_player/models/alist/file_info.dart';
import 'package:bunga_player/models/alist/search_result.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NetDiskDialog extends StatefulWidget {
  final Locator read;
  const NetDiskDialog({super.key, required this.read});
  @override
  State<NetDiskDialog> createState() => _NetDiskDialogState();
}

class AbortException implements Exception {}

class CancelException implements Exception {}

class _NetDiskDialogState extends State<NetDiskDialog> {
  Completer? _work;
  bool get _pending => _work != null;
  String _currentPath = '';
  List<AListFileInfo> _currentFiles = [];

  // Search
  bool _searchMode = false;
  List<AListSearchResult> _searchResults = [];
  late final FocusNode _searchFieldFocusNode = FocusNode();

  // Bookmarks
  late final _alistBookmarks =
      getIt<Preferences>().get<List<String>>('alist_bookmarks') ?? [];

  @override
  void initState() {
    final lastPath = getIt<Preferences>().get<String>('alist_last_path') ?? '/';
    Future.microtask(() => _cd(lastPath));
    super.initState();
  }

  @override
  void dispose() {
    getIt<Preferences>().set('alist_bookmarks', _alistBookmarks);
    getIt<Preferences>().set('alist_last_path', _currentPath);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    String ellipseStart(String path) {
      final splits = path.split('/')..removeWhere((e) => e.isEmpty);
      if (splits.length <= 2) return path;

      splits.removeRange(0, splits.length - 2);
      return '.../${splits.join('/')}';
    }

    final itemCount =
        _searchMode ? _searchResults.length : _currentFiles.length;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      title: IndexedStack(
        index: _searchMode ? 1 : 0,
        children: [
          Row(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(ellipseStart(_currentPath)),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: () => _cd('..'),
                icon: const Icon(Icons.subdirectory_arrow_left),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: () => setState(() {
                  _alistBookmarks.add(_currentPath);
                }),
                icon: const Icon(Icons.bookmark_add),
              ),
              const Spacer(),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    _searchMode = true;
                  });
                  _searchFieldFocusNode.requestFocus();
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          TextField(
            focusNode: _searchFieldFocusNode,
            decoration: InputDecoration(
              hintText: '搜索文件和文件夹',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _searchMode = false;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSubmitted: _search,
          ),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 36,
              child: ListView.separated(
                itemCount: _alistBookmarks.length + 1,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return InputChip(
                      label: const Text('主目录'),
                      avatar: Icon(
                        Icons.home,
                        color: themeData.indicatorColor,
                      ),
                      onPressed: () => _cd('/'),
                    );
                  }

                  final path = _alistBookmarks[index - 1];
                  return InputChip(
                    label: Text(getName(path)),
                    avatar: Icon(
                      Icons.bookmark,
                      color: themeData.indicatorColor,
                    ),
                    deleteButtonTooltipMessage: '',
                    onDeleted: () => setState(() {
                      _alistBookmarks.removeAt(index - 1);
                    }),
                    onPressed: () => _cd(path),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 8),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: themeData.colorScheme.surface,
                  ),
                  child: _pending
                      ? Column(
                          children: [
                            const LinearProgressIndicator(),
                            Expanded(
                              child: Center(
                                child: OutlinedButton(
                                    onPressed: () =>
                                        _work!.completeError(CancelException()),
                                    child: const Text('取消')),
                              ),
                            ),
                          ],
                        )
                      : itemCount == 0
                          ? Center(
                              child: Text(
                              '无结果',
                              style: themeData.textTheme.labelMedium,
                            ))
                          : ListView.separated(
                              itemCount: itemCount,
                              itemBuilder: (context, index) {
                                if (_searchMode) {
                                  final result = _searchResults[index];
                                  return ListTile(
                                    leading: Icon(switch (result.type) {
                                      AListFileType.folder => Icons.folder,
                                      AListFileType.video => Icons.movie,
                                      AListFileType.audio => Icons.music_note,
                                      AListFileType.text => Icons.description,
                                      AListFileType.image => Icons.image,
                                      AListFileType.unknown => Icons.note,
                                    }),
                                    title: Row(children: [
                                      Expanded(child: Text(result.name)),
                                      if (result.type != AListFileType.folder)
                                        IconButton.outlined(
                                          onPressed: () {
                                            _searchMode = false;
                                            _cd('${result.parent}/');
                                          },
                                          icon:
                                              const Icon(Icons.drive_file_move),
                                        )
                                    ]),
                                    onTap: switch (result.type) {
                                      AListFileType.folder => () {
                                          _searchMode = false;
                                          _cd('${result.parent}/${result.name}/');
                                        },
                                      AListFileType.video => () {
                                          final p =
                                              '${result.parent}/${result.name}';
                                          Navigator.pop(context, AListEntry(p));
                                        },
                                      AListFileType.audio => null,
                                      AListFileType.text => null,
                                      AListFileType.image => null,
                                      AListFileType.unknown => null,
                                    },
                                  );
                                }

                                final info = _currentFiles[index];
                                final videoHash =
                                    AListEntry('$_currentPath${info.name}')
                                        .hash;
                                final percent = widget
                                    .read<PlayWatchProgresses>()
                                    .get(videoHash)
                                    ?.percent;
                                final tile = ListTile(
                                  leading: Icon(switch (info.type) {
                                    AListFileType.folder => Icons.folder,
                                    AListFileType.video => Icons.movie,
                                    AListFileType.audio => Icons.music_note,
                                    AListFileType.text => Icons.description,
                                    AListFileType.image => Icons.image,
                                    AListFileType.unknown => Icons.note,
                                  }),
                                  title: Text(info.name),
                                  subtitle: percent != null
                                      ? Text('已看 ${(percent * 100).toInt()}%')
                                      : null,
                                  onTap: switch (info.type) {
                                    AListFileType.folder => () =>
                                        _cd('${info.name}/'),
                                    AListFileType.video => () {
                                        final p = '$_currentPath${info.name}';
                                        Navigator.pop(context, AListEntry(p));
                                      },
                                    AListFileType.audio => null,
                                    AListFileType.text => null,
                                    AListFileType.image => null,
                                    AListFileType.unknown => null,
                                  },
                                );

                                bool clickable = {
                                  AListFileType.folder,
                                  AListFileType.video,
                                }.contains(info.type);
                                return Opacity(
                                  opacity: clickable ? 1.0 : 0.7,
                                  child: tile,
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
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
      ],
    );
  }

  String getName(String path) {
    final split = path.split('/')..removeWhere((e) => e.isEmpty);
    return split.isEmpty ? '' : split.last;
  }

  late String _lastSuccessPath = _currentPath;
  void _cd(String path) async {
    final newPath = Uri.decodeFull(Uri(path: _currentPath).resolve(path).path);
    if (newPath == _currentPath) return;
    _currentPath = newPath;

    try {
      _currentFiles = await createNewWork(getIt<AList>().list(newPath));
      _lastSuccessPath = newPath;
    } catch (e) {
      if (e is! AbortException) {
        _currentPath = _lastSuccessPath;
        if (e is! CancelException) rethrow;
      }
    } finally {
      if (mounted) {
        setState(() {
          _work = null;
        });
      }
    }
  }

  void _refresh() async {
    try {
      _currentFiles = await createNewWork(
        getIt<AList>().list(
          _currentPath,
          refresh: true,
        ),
      );
    } catch (e) {
      if (![AbortException, CancelException].contains(e.runtimeType)) rethrow;
    } finally {
      setState(() {
        _work = null;
      });
    }
  }

  void _search(String keywords) async {
    try {
      _searchResults = await createNewWork(getIt<AList>().search(keywords));
    } catch (e) {
      if (![AbortException, CancelException].contains(e.runtimeType)) rethrow;
    } finally {
      setState(() {
        _work = null;
      });
    }
  }

  Future<T> createNewWork<T>(Future<T> things) async {
    if (_pending) {
      _work!.completeError(AbortException());
      _work = null;
      await Future.microtask(() {});
    }

    final completer = Completer<T>();
    setState(() {
      _work = completer;
    });

    things.then((value) {
      if (!completer.isCompleted) completer.complete(value);
    }).onError((error, stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(error ?? 'Unknown error');
      }
    });

    return completer.future;
  }
}
