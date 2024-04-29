import 'dart:async';

import 'package:bunga_player/models/alist/file_info.dart';
import 'package:bunga_player/models/alist/search_result.dart';
import 'package:bunga_player/models/video_entries/video_entry.dart';
import 'package:bunga_player/providers/clients/alist.dart';
import 'package:bunga_player/services/player.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/iterable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AbortException implements Exception {}

class CancelException implements Exception {}

class NetDiskDialog extends StatefulWidget {
  static const dialogWidth = 640.0;

  const NetDiskDialog({super.key});
  @override
  State<NetDiskDialog> createState() => _NetDiskDialogState();
}

class _NetDiskDialogState extends State<NetDiskDialog> {
  // Directory
  Completer? _work;
  bool get _pending => _work != null;
  String _currentPath = '';
  List<AListFileInfo> _currentFiles = [];
  final _dirScrollController = ScrollController();

  // Search
  bool _searchMode = false;
  List<AListSearchResult> _searchResults = [];
  late final FocusNode _searchFieldFocusNode = FocusNode();

  // Bookmarks
  late final _alistBookmarks =
      getIt<Preferences>().get<List<String>>('alist_bookmarks') ?? [];
  final _bookmarksScrollController = ScrollController();

  @override
  void initState() {
    final lastPath = getIt<Preferences>().get<String>('alist_last_path') ?? '/';
    Future.microtask(() => _cd(lastPath));
    super.initState();
  }

  @override
  void dispose() {
    _bookmarksScrollController.dispose();
    getIt<Preferences>().set('alist_bookmarks', _alistBookmarks);
    getIt<Preferences>().set('alist_last_path', _currentPath);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final itemCount =
        _searchMode ? _searchResults.length : _currentFiles.length;

    final pathSplits = _currentPath.split('/');
    final pathSection = Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.purple],
                  stops: [0.95, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstOut,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                controller: _dirScrollController,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 24 : 0,
                    right: index == pathSplits.length - 2 ? 24 : 0,
                  ),
                  child: FilledButton.tonal(
                    onPressed: () {
                      final cdPath = pathSplits.sublist(0, index + 1).join('/');
                      _cd('$cdPath/');
                    },
                    child: Text(
                      index == 0 ? '所有文件' : pathSplits[index],
                      style: themeData.textTheme.bodyLarge,
                    ),
                  ),
                ),
                separatorBuilder: (context, index) =>
                    const Center(child: Icon(Icons.chevron_right)),
                itemCount: pathSplits.length - 1,
              ),
            ),
          ),
        ),
        IconButton.filled(
          onPressed: () {
            setState(() {
              _searchMode = true;
            });
            _searchFieldFocusNode.requestFocus();
          },
          icon: const Icon(Icons.search),
        ),
        const SizedBox(width: 24),
      ],
    );
    final bookmarkSection = SizedBox(
      height: 36,
      width: double.maxFinite,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: _bookmarksScrollController,
        children: <Widget>[
          const SizedBox(width: 16),
          ..._alistBookmarks.map(
            (path) => InputChip(
              label: Text(getName(path)),
              avatar: const Icon(Icons.bookmark),
              deleteButtonTooltipMessage: '',
              onDeleted: () => setState(() {
                _alistBookmarks.remove(path);
              }),
              onPressed: () => _cd(path),
            ),
          ),
          if (!_alistBookmarks.contains(_currentPath) && _currentPath != '/')
            ActionChip(
              label: const Text('添加书签'),
              avatar: Icon(
                Icons.add,
                color: themeData.colorScheme.tertiary,
              ),
              onPressed: () => setState(() {
                _alistBookmarks.add(_currentPath);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _bookmarksScrollController.animateTo(
                    _bookmarksScrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  );
                });
              }),
            ),
          const SizedBox(width: 16),
        ].alternateWith(const SizedBox(width: 8)).toList(),
      ),
    );
    final dirTitleBar = Column(
      children: [
        pathSection,
        const SizedBox(height: 8),
        bookmarkSection,
        const SizedBox(height: 8),
      ],
    );

    final searchTitleBar = Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: TextField(
        focusNode: _searchFieldFocusNode,
        decoration: InputDecoration(
          hintText: '搜索文件和文件夹',
          border: const OutlineInputBorder(),
          fillColor: Colors.red,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchMode = false;
                });
              },
            ),
          ),
        ),
        onSubmitted: _search,
      ),
    );

    final dialogTitle = SizedBox(
      width: NetDiskDialog.dialogWidth,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        child: _searchMode ? searchTitleBar : dirTitleBar,
      ),
    );

    final pendingIndicator = Column(
      children: [
        const LinearProgressIndicator(),
        Expanded(
          child: Center(
            child: OutlinedButton(
                onPressed: () => _work!.completeError(CancelException()),
                child: const Text('取消')),
          ),
        ),
      ],
    );
    final emptyIndicator = Center(
        child: Text(
      '无结果',
      style: themeData.textTheme.labelMedium,
    ));
    final listView = ListView.separated(
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
            title: Expanded(child: Text(result.name)),
            trailing: result.type != AListFileType.folder
                ? IconButton.outlined(
                    onPressed: () {
                      _searchMode = false;
                      _cd('${result.parent}/');
                    },
                    icon: const Icon(Icons.drive_file_move),
                  )
                : null,
            onTap: switch (result.type) {
              AListFileType.folder => () {
                  _searchMode = false;
                  _cd('${result.parent}/${result.name}/');
                },
              AListFileType.video => () {
                  final p = '${result.parent}/${result.name}';
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
        final videoHash = AListEntry('$_currentPath${info.name}').hash;
        final percent = getIt<Player>().watchProgresses.get(videoHash)?.percent;
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
          subtitle:
              percent != null ? Text('已看 ${(percent * 100).toInt()}%') : null,
          onTap: switch (info.type) {
            AListFileType.folder => () => _cd('${info.name}/'),
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
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
    final dialogContent = SizedBox(
      width: NetDiskDialog.dialogWidth,
      child: Scaffold(
        body: Ink(
          color: themeData.colorScheme.surface,
          child: _pending
              ? pendingIndicator
              : itemCount == 0
                  ? emptyIndicator
                  : listView,
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: _refresh,
          tooltip: '刷新',
          child: const Icon(Icons.refresh),
        ),
      ),
    );

    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      titlePadding: const EdgeInsets.only(top: 24.0),
      title: dialogTitle,
      contentPadding: const EdgeInsets.only(bottom: 24.0),
      content: dialogContent,
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
      _currentFiles =
          await createNewWork(context.read<AListClient>().list(newPath));
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _dirScrollController.animateTo(
              _dirScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          });
        });
      }
    }
  }

  void _refresh() async {
    try {
      _currentFiles = await createNewWork(
        context.read<AListClient>().list(
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
      _searchResults =
          await createNewWork(context.read<AListClient>().search(keywords));
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
