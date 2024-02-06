import 'package:bunga_player/models/alist/file_info.dart';
import 'package:bunga_player/models/alist/search_result.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';

class NetDiskDialog extends StatefulWidget {
  const NetDiskDialog({super.key});
  @override
  State<NetDiskDialog> createState() => _NetDiskDialogState();
}

class _NetDiskDialogState extends State<NetDiskDialog> {
  bool _pending = false;
  String _currentPath = '';
  List<AListFileInfo> _currentFiles = [];

  // Search
  bool _searchMode = false;
  List<AListSearchResult> _searchResults = [];

  // Bookmarks
  late final _alistBookmarks =
      getService<Preferences>().get<List<String>>('alist_bookmarks') ?? [];

  @override
  void initState() {
    Future.microtask(() => _cd('/'));
    super.initState();
  }

  @override
  void dispose() {
    getService<Preferences>().set('alist_bookmarks', _alistBookmarks);
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

    return AlertDialog(
      insetPadding: const EdgeInsets.all(40),
      title: IndexedStack(
        index: _searchMode ? 1 : 0,
        children: [
          Row(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 420),
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
                onPressed: () => setState(() {
                  _alistBookmarks.add(_currentPath);
                }),
                icon: const Icon(Icons.bookmark_add),
              ),
              const Spacer(),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    _searchMode = true;
                  });
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          TextField(
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
        width: 600,
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
            const SizedBox(height: 16),
            Expanded(
              child: _pending
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _searchMode
                          ? _searchResults.length
                          : _currentFiles.length,
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
                                  icon: const Icon(Icons.drive_file_move),
                                )
                            ]),
                            onTap: switch (result.type) {
                              AListFileType.folder => () {
                                  _searchMode = false;
                                  _cd('${result.parent}/${result.name}/');
                                },
                              AListFileType.video => () => Navigator.pop(
                                  context, '${result.parent}/${result.name}'),
                              AListFileType.audio => null,
                              AListFileType.text => null,
                              AListFileType.image => null,
                              AListFileType.unknown => null,
                            },
                          );
                        }

                        final info = _currentFiles[index];
                        return ListTile(
                          leading: Icon(switch (info.type) {
                            AListFileType.folder => Icons.folder,
                            AListFileType.video => Icons.movie,
                            AListFileType.audio => Icons.music_note,
                            AListFileType.text => Icons.description,
                            AListFileType.image => Icons.image,
                            AListFileType.unknown => Icons.note,
                          }),
                          title: Text(info.name),
                          // TODO: show watch progress
                          //subtitle: Text('已看 58%'),
                          onTap: switch (info.type) {
                            AListFileType.folder => () => _cd('${info.name}/'),
                            AListFileType.video => () => Navigator.pop(
                                context, '$_currentPath${info.name}'),
                            AListFileType.audio => null,
                            AListFileType.text => null,
                            AListFileType.image => null,
                            AListFileType.unknown => null,
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
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

  void _cd(String path) async {
    final newPath = Uri.decodeFull(Uri(path: _currentPath).resolve(path).path);
    if (newPath == _currentPath) return;

    final oldPath = _currentPath;
    setState(() {
      _currentPath = newPath;
      _pending = true;
    });

    try {
      _currentFiles = await getService<AList>().list(_currentPath);
    } catch (e) {
      // TODO: change showToast to provider
      //if (context.mounted) context.showToast('获取目录失败');
      _currentPath = oldPath;
      rethrow;
    } finally {
      setState(() {
        _pending = false;
      });
    }
  }

  void _search(String keywords) async {
    setState(() {
      _pending = true;
    });

    try {
      _searchResults = await getService<AList>().search(keywords);
    } finally {
      setState(() {
        _pending = false;
      });
    }
  }
}
