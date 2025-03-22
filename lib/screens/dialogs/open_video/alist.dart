import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_tool;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/alist/models.dart';
import 'package:bunga_player/alist/business.dart';
import 'package:bunga_player/alist/extensions.dart';
import 'package:bunga_player/play/models/history.dart';
import 'package:bunga_player/screens/widgets/scroll_optimizer.dart';
import 'package:bunga_player/screens/dialogs/open_video/history.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/utils/extensions/int.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

class _AListPrefKey {
  static const recent = 'alist_recent';
  static const last = 'alist_last_path';
}

class AbortException implements Exception {}

class CancelException implements Exception {}

class AListTab extends StatefulWidget {
  const AListTab({super.key});
  @override
  State<AListTab> createState() => _AListTabState();
}

class _AListTabState extends State<AListTab> {
  // Directory
  Completer? _work;
  bool get _pending => _work != null;
  String _currentPath = '';
  List<AListFileDetail> _currentFiles = [];
  final _dirScrollController = ScrollController();

  // Search
  bool _searchMode = false;
  List<AListSearchResult> _searchResults = [];
  late final FocusNode _searchFieldFocusNode = FocusNode();

  // Recent
  final _recentScrollController = ScrollController();
  final _recentPaths =
      getIt<Preferences>().getOrCreate<List<String>>(_AListPrefKey.recent, []);
  bool _showRemoveRecent = false;

  @override
  void initState() {
    final lastPath =
        getIt<Preferences>().getOrCreate<String>(_AListPrefKey.last, '/');
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cd(lastPath);
    });
  }

  @override
  void dispose() {
    _dirScrollController.dispose();
    _recentScrollController.dispose();

    final pref = getIt<Preferences>();
    pref.set(_AListPrefKey.last, _currentPath);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final itemCount =
        _searchMode ? _searchResults.length : _currentFiles.length;

    final pathSplits = _currentPath.split('/')..removeLast();
    final pathSection = [
      pathSplits
          .asMap()
          .entries
          .map(
            (entry) => FilledButton.tonal(
              onPressed: () {
                final cdPath = pathSplits.sublist(0, entry.key + 1).join('/');
                _cd('$cdPath/');
              },
              child: Text(entry.key == 0 ? '网盘文件' : entry.value),
            ),
          )
          .toList()
          .toRow(separator: const Center(child: Icon(Icons.chevron_right)))
          .scrollable(
            scrollDirection: Axis.horizontal,
            controller: _dirScrollController,
            padding: const EdgeInsets.only(left: 16.0, right: 24.0),
          )
          .scrollOptimizer(_dirScrollController)
          .fadeOutShader()
          .expanded(),
      StyledWidget(IconButton(
        onPressed: () {
          setState(() {
            _searchMode = true;
          });
          _searchFieldFocusNode.requestFocus();
        },
        icon: const Icon(Icons.search),
      )).padding(right: 16.0),
    ].toRow();
    final recentSection = _recentPaths.isEmpty
        ? const SizedBox.shrink()
        : <Widget>[
            const Icon(Icons.schedule, size: 14.0)
                .opacity(0.8)
                .padding(left: 16.0),
            const Text('最近').padding(left: 4.0, right: 12.0),
            _recentPaths
                .map(
                  (path) => InputChip(
                    key: ValueKey(path),
                    label: Text(path_tool.basename(path)),
                    tooltip: path,
                    onPressed: () => _cd(path),
                    deleteButtonTooltipMessage: '删除',
                    onDeleted: _showRemoveRecent
                        ? () => setState(() {
                              _recentPaths.remove(path);
                              getIt<Preferences>()
                                  .set(_AListPrefKey.recent, _recentPaths);
                            })
                        : null,
                  ),
                )
                .toList()
                .toRow(separator: const SizedBox(width: 8))
                .scrollable(
                  scrollDirection: Axis.horizontal,
                  controller: _recentScrollController,
                  padding: EdgeInsets.only(right: 16.0),
                )
                .scrollOptimizer(_recentScrollController)
                .fadeOutShader()
                .expanded(),
            StyledWidget(ChoiceChip(
              selected: _showRemoveRecent,
              showCheckmark: false,
              avatar: const Icon(Icons.delete),
              label: const Text('删除'),
              onSelected: (value) {
                setState(() {
                  _showRemoveRecent = value;
                });
              },
            )).padding(horizontal: 12.0),
          ].toRow().padding(top: 16.0);
    final dirTitleBar = [
      pathSection,
      recentSection,
    ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .padding(top: 16.0);

    final searchTitleBar = TextField(
      focusNode: _searchFieldFocusNode,
      decoration: InputDecoration(
        hintText: '搜索文件和文件夹',
        border: const OutlineInputBorder(),
        suffixIcon: StyledWidget(IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchMode = false;
            });
          },
        )).padding(right: 8.0),
      ),
      onSubmitted: _search,
    ).padding(horizontal: 24.0, bottom: 4.0);

    final dialogTitle =
        (_searchMode ? searchTitleBar : dirTitleBar).animatedSize(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );

    final emptyIndicator =
        const Text('无结果').textStyle(themeData.textTheme.labelMedium!).center();
    final listView = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (_searchMode) {
          final result = _searchResults[index];
          onTapFolder() {
            _searchMode = false;
            _cd('${result.parent}/');
          }

          final onTap = switch (result.type) {
            AListFileType.folder => () {
                _searchMode = false;
                _cd('${result.parent}/${result.name}/');
              },
            AListFileType.video => () {
                final url = Uri(
                  scheme: 'alist',
                  path: '${result.parent}/${result.name}',
                );
                Actions.invoke(context, SelectUrlIntent(url));
              },
            AListFileType.audio ||
            AListFileType.text ||
            AListFileType.image ||
            AListFileType.unknown =>
              null,
          };
          return _SearchEntry(
            result: result,
            onTap: onTap,
            onTapFolder: onTapFolder,
          );
        } else {
          final info = _currentFiles[index];
          final path = '$_currentPath${info.name}';
          final percent = context
              .read<History>()
              .value[path.asPathToAListId()]
              ?.progress
              ?.ratio;
          final onTap = switch (info.type) {
            AListFileType.folder => () => _cd('${info.name}/'),
            AListFileType.video => () {
                _updatePref();
                final url = Uri(scheme: 'alist', path: path);
                Actions.invoke(context, SelectUrlIntent(url));
              },
            AListFileType.audio ||
            AListFileType.text ||
            AListFileType.image ||
            AListFileType.unknown =>
              null,
          };

          return _DirEntry(
            info: info,
            watchPercent: percent,
            onTap: onTap,
          );
        }
      },
    );
    final dialogContent = Scaffold(
      body: [
        if (_pending) const LinearProgressIndicator(),
        (itemCount == 0 ? emptyIndicator : listView),
      ].toStack(),
      backgroundColor: themeData.colorScheme.surfaceContainer,
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: '刷新',
        child: const Icon(Icons.refresh),
      ),
    );

    return [
      dialogTitle,
      dialogContent.padding(top: 8.0).flexible(),
    ].toColumn();
  }

  late String _lastSuccessPath = _currentPath;
  void _cd(String path) async {
    final newPath = Uri.decodeFull(Uri(path: _currentPath).resolve(path).path);
    if (newPath == _currentPath) return;
    _currentPath = newPath;

    try {
      _currentFiles = await createNewWork(
          Actions.invoke(context, ListIntent(newPath))
              as Future<List<AListFileDetail>>);
      _currentFiles.sort();
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
        Actions.invoke(context, ListIntent(_currentPath, refresh: true))
            as Future<List<AListFileDetail>>,
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
      _searchResults = await createNewWork(
          Actions.invoke(context, SearchIntent(keywords))
              as Future<List<AListSearchResult>>);
      _searchResults.sort();
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

  void _updatePref() {
    final pref = getIt<Preferences>();
    _recentPaths.remove(_currentPath);
    _recentPaths.insert(0, _currentPath);
    pref.set(
      _AListPrefKey.recent,
      _recentPaths.sublist(0, min(_recentPaths.length, 10)),
    );
  }
}

const _tileLeading = {
  AListFileType.folder: Icons.folder,
  AListFileType.video: Icons.movie,
  AListFileType.audio: Icons.music_note,
  AListFileType.text: Icons.description,
  AListFileType.image: Icons.image,
  AListFileType.unknown: Icons.note,
};

class _DirEntry extends StatelessWidget {
  final AListFileDetail info;
  final double? watchPercent;
  final VoidCallback? onTap;

  const _DirEntry({
    required this.info,
    this.watchPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      leading: (info.thumb.isEmpty
              ? Icon(_tileLeading[info.type]).iconSize(32.0).center()
              : Image.network(
                  info.thumb,
                  fit: BoxFit.cover,
                  height: double.maxFinite,
                ))
          .constrained(width: 60)
          .clipRRect(all: 16.0),
      title: (watchPercent == null
              ? Text(info.name)
              : TitleWithProgress(title: info.name, progress: watchPercent!))
          .padding(bottom: 4.0),
      subtitle: info.type == AListFileType.folder
          ? null
          : Text(info.size.formatBytes),
      onTap: onTap,
    );

    return tile.opacity(onTap != null ? 1.0 : 0.7);
  }
}

class _SearchEntry extends StatelessWidget {
  final AListSearchResult result;
  final VoidCallback? onTap;
  final VoidCallback onTapFolder;

  const _SearchEntry({
    required this.result,
    this.onTap,
    required this.onTapFolder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(_tileLeading[result.type]),
      title: RichText(
        text: TextSpan(
          text: result.name,
          style: theme.textTheme.bodyLarge,
          children: [
            const TextSpan(text: '  '),
            if (result.type != AListFileType.folder)
              TextSpan(
                text: result.size.formatBytes,
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
      ),
      subtitle: Text(result.parent),
      trailing: result.type != AListFileType.folder
          ? IconButton.filledTonal(
              onPressed: onTapFolder,
              icon: const Icon(Icons.drive_file_move),
              tooltip: '跳转到目录',
            )
          : null,
      onTap: onTap,
    );
  }
}

extension _ShaderMaskStyle on Widget {
  Widget fadeOutShader() => ShaderMask(
        shaderCallback: (Rect rect) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, Colors.purple],
          stops: [0.98, 1.0],
        ).createShader(rect),
        blendMode: BlendMode.dstOut,
        child: this,
      );
}
