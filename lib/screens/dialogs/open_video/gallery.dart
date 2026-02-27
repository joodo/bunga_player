import 'package:animations/animations.dart';
import 'package:bunga_player/gallery/models/models.dart';
import 'package:bunga_player/play/history.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/screens/widgets/input_builder.dart';
import 'package:bunga_player/screens/widgets/scroll_optimizer.dart';
import 'package:bunga_player/screens/widgets/widgets.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/business/image.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/utils/models/file_extensions.dart';
import 'package:bunga_player/gallery/business.dart' as gallery;
import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'open_video.dart';

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator =
        Navigator(
          initialRoute: 'search',
          observers: [HeroController()],
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case 'search':
                builder = (context) => _SearchPage();
                break;
              case 'results':
                builder = (context) => _ResultPage();
                break;
              case 'detail':
                builder = (context) => _DetailPage();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return MaterialPageRoute(builder: builder, settings: settings);
          },
        ).theme(
          data: Theme.of(context).copyWith(
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: const SharedAxisPageTransitionsBuilder(
                    transitionType: SharedAxisTransitionType.horizontal,
                  ),
              },
            ),
          ),
        );

    return ChangeNotifierProvider(
      create: (context) => gallery.HistoryNotifier(),
      child: navigator,
    );
  }
}

const _searchBarHintText = '打开链接或搜索片名';
const _searchBarMaxWidth = 500.0;

class _SearchPage extends StatefulWidget {
  const _SearchPage();

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final _carouselController = CarouselController();

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchSection = InputBuilder(
      builder: (context, textEditingController, focusNode, child) =>
          ValueListenableBuilder(
            valueListenable: textEditingController,
            builder: (context, editingValue, child) {
              final currentUrl = editingValue.text.extractUrls().firstOrNull;

              final searchBar = SearchBar(
                hintText: _searchBarHintText,
                autoFocus: true,
                controller: textEditingController,
                focusNode: focusNode,
                leading: Icon(currentUrl == null ? Icons.search : Icons.link),
                onSubmitted: (value) =>
                    _onSubmit(context, textEditingController),
              );

              final buttonRow =
                  [
                    FilledButton(
                      onPressed: editingValue.text.isNotEmpty
                          ? () => _onSubmit(context, textEditingController)
                          : null,
                      child: Text(currentUrl == null ? '搜索' : '打开').fontSize(
                        Theme.of(context).textTheme.titleMedium?.fontSize,
                      ),
                    ),
                    child!,
                  ].toRow(
                    mainAxisSize: .min,
                    separator: const SizedBox(width: 16.0),
                  );

              return [
                searchBar
                    .hero(tag: 'search-bar')
                    .constrained(maxWidth: _searchBarMaxWidth),
                buttonRow,
              ].toColumn(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                separator: const SizedBox(height: 16.0),
              );
            },
            child: child,
          ),
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
    );

    final historyNotifier = context.read<gallery.HistoryNotifier>();
    final historySection = ValueListenableBuilder(
      valueListenable: historyNotifier,
      builder: (context, historys, child) {
        if (historys.isEmpty) return const SizedBox.shrink();
        return CarouselView.weighted(
              flexWeights: const [3, 3, 3, 1],
              consumeMaxWeight: false,
              itemSnapping: true,
              enableSplash: false,
              elevation: 4.0,
              controller: _carouselController,
              children: [
                ...historys.map(
                  (e) => _MediaTile(item: e.item, linkerId: e.linkerId)
                      .contextMenu(
                        items: [
                          PopupMenuItem(
                            child: const Text('删除'),
                            onTap: () => historyNotifier.remove(
                              linkerId: e.linkerId,
                              itemKey: e.item.key,
                            ),
                          ),
                        ],
                      ),
                ),
                if (historys.length >= 3)
                  Card(
                    child: InkWell(
                      onTap: Actions.handler(
                        context,
                        SwitchTabIntent(index: 2),
                      ),
                      child: Icon(Icons.more_horiz).center(),
                    ),
                  ),
              ],
            )
            .scrollOptimizer(_carouselController)
            .constrained(maxWidth: 720.0, height: 300.0);
      },
    );

    return [searchSection, historySection]
        .toColumn(mainAxisSize: .min, separator: const SizedBox(height: 24.0))
        .padding(horizontal: 16.0)
        .center();
  }

  void _onSubmit(BuildContext context, TextEditingController controller) async {
    final text = controller.text;

    final url = text.extractUrls().firstOrNull;
    if (url != null) {
      Actions.invoke(context, SelectUrlIntent(Uri.parse(url)));
    } else {
      await Navigator.of(context).pushNamed('results', arguments: text);
      controller.clear();
    }
  }
}

class _ResultPage extends StatefulWidget {
  @override
  State<_ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<_ResultPage> {
  static final _fakeData = List<gallery.SummaryWithLinkerId>.filled(10, (
    linkerId: BoneMock.words(1),
    item: MediaSummary(key: BoneMock.words(1), title: BoneMock.title),
  ));
  bool _isBusy = false;
  List<gallery.SummaryWithLinkerId> _data = [];

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    runAfterBuild(() {
      _textController.text =
          ModalRoute.of(context)!.settings.arguments as String;
      _onSearch();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchBar = SearchBar(
      hintText: _searchBarHintText,
      autoFocus: true,
      controller: _textController,
      leading: const BackButton(),
      onSubmitted: (value) => _onSearch(),
      trailing: [IconButton(icon: Icon(Icons.search), onPressed: _onSearch)],
    );

    Widget? tileBuilder(BuildContext context, int index) {
      final (linkerId: linkerId, item: item) = _data[index];

      final tile = _MediaTile(item: item, linkerId: linkerId);

      return Skeleton.leaf(child: tile);
    }

    final grid = SliverGrid.builder(
      itemCount: _data.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 24.0,
        crossAxisSpacing: 20.0,
        childAspectRatio: 0.7,
      ),
      itemBuilder: tileBuilder,
    );

    final scrollView = CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          expandedHeight: 80.0,
          leading: const SizedBox.shrink(),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: searchBar
                  .hero(tag: "search-bar")
                  .constrained(maxWidth: 500.0)
                  .padding(horizontal: 16.0)
                  .center(),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: Skeletonizer.sliver(enabled: _isBusy, child: grid),
        ),
      ],
    );

    return scrollView;
  }

  void _onSearch() async {
    final text = _textController.text;
    final url = text.extractUrls().firstOrNull;
    if (url != null) {
      Actions.invoke(context, SelectUrlIntent(Uri.parse(url)));
      return;
    }

    setState(() {
      _data = _fakeData;
      _isBusy = true;
    });

    try {
      final results = await gallery.search(context, text);

      _data = results.values
          .map((e) {
            return e.results.map((r) => (linkerId: e.info.id, item: r));
          })
          .expand((i) => i)
          .toList();
    } catch (e) {
      logger.w('Search in gallery failed: $e');
      if (mounted) context.popBar('搜索失败，请重试');
      rethrow;
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }
}

typedef _DetailPageArg = ({String linkerId, MediaSummary summary});

class _MediaTile extends StatelessWidget {
  final MediaSummary item;
  final String linkerId;
  const _MediaTile({required this.item, required this.linkerId});

  @override
  Widget build(BuildContext context) {
    final image = Ink.image(
      image: item.thumbUrl != null
          ? NetworkImage(item.thumbUrl!)
          : transparentImageProvider,
      fit: .cover,
      child: InkWell(
        onTap: () {
          final _DetailPageArg args = (linkerId: linkerId, summary: item);
          Navigator.of(context).pushNamed('detail', arguments: args);
        },
      ),
    ).material();

    final tile = GridTile(
      footer: GridTileBar(
        title: Text(item.title),
        subtitle: Text(
          '${item.country} / ${item.year}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        backgroundColor: Colors.black54,
      ).ignorePointer(ignoring: true),
      child: image,
    ).clipRRect(all: 16.0);

    return tile.hero(tag: '$linkerId/${item.key}');
  }
}

class _DetailPage extends StatelessWidget {
  static final _fakeData = Media(
    title: BoneMock.words(5),
    origin: BoneMock.email,
    aka: BoneMock.words(10),
    cast: List.filled(4, BoneMock.fullName),
    country: BoneMock.country,
    director: List.filled(3, BoneMock.fullName),
    genres: List.filled(3, BoneMock.words(1)),
    summary: BoneMock.longParagraph,
    year: 2000,
    episodes: List.filled(
      12,
      Episode(id: BoneMock.words(1), title: BoneMock.title),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = ModalRoute.of(context)!.settings.arguments as _DetailPageArg;

    return FutureBuilder(
          future: gallery.detail(context, args.linkerId, args.summary.key),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              runAfterBuild(() => context.popBar('拉取影片信息失败'));
              logger.w(
                'Fetch media ${args.linkerId}/${args.summary.key} failed: ${snapshot.error}',
              );
            }

            final item = snapshot.data ?? _fakeData;
            if (snapshot.hasData) {
              final notifier = context.read<gallery.HistoryNotifier>();
              runAfterBuild(
                () => notifier.update(
                  linkerId: args.linkerId,
                  item: args.summary,
                ),
              );
            }

            final sortedEps = item.episodes.sorted(
              (a, b) => compareNatural(a.title, b.title),
            );
            final epProgress = _getEpProgress(context, args, sortedEps);
            final header =
                [
                  const BackButton(),
                  snapshot.hasData
                      ? _createPlayButton(context, args, sortedEps, epProgress)
                      : const FilledButton(
                          onPressed: null,
                          child: SizedBox(width: 100),
                        ),
                  IconButton(
                    icon: Icon(Icons.star_border),
                    selectedIcon: Icon(Icons.star),
                    tooltip: '收藏',
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.open_in_new),
                    tooltip: '浏览器中打开',
                    onPressed: snapshot.hasData
                        ? () => launchUrl(Uri.parse(item.origin))
                        : null,
                  ),
                ].toRow(
                  crossAxisAlignment: .center,
                  separator: const SizedBox(width: 12.0),
                );

            final yearPrefix = item.year != null ? '${item.year}, ' : '';
            final subtitle = '$yearPrefix${item.country ?? ''}';

            final rowList =
                [
                      ('又名', item.aka),
                      ('导演', item.director),
                      ('主演', item.cast),
                      ('类型', item.genres),
                    ]
                    .map((e) => _createRow(context, e.$1, e.$2))
                    .whereType<TableRow>()
                    .toList();

            final info =
                [
                  SelectableText(
                    item.title,
                    style: theme.textTheme.headlineMedium,
                  ),
                  if (subtitle.isNotEmpty)
                    SelectableText(subtitle, style: theme.textTheme.titleSmall),

                  SelectableText(
                    item.summary ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ).padding(top: 16.0),

                  if (rowList.isNotEmpty)
                    Skeleton.keep(
                      child: Text('基本信息', style: theme.textTheme.titleMedium),
                    ).padding(top: 16.0),
                  if (rowList.isNotEmpty)
                    Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: rowList,
                    ).constrained(width: 400.0),

                  Skeleton.keep(
                    child: Text('选集', style: theme.textTheme.titleMedium),
                  ).padding(top: 16.0),
                  sortedEps
                      .map((e) {
                        final progress = epProgress[e.id];
                        final title = progress == null
                            ? e.title
                            : progress > 0.90
                            ? '${e.title} (已看完)'
                            : '${e.title} (已看 ${progress.toLevel}%)';
                        return ActionChip(
                          label: Text(title),
                          avatar: const Icon(Icons.play_arrow_rounded),
                          onPressed: Actions.handler(
                            context,
                            SelectUrlIntent(
                              gallery.createUrl(
                                args.linkerId,
                                args.summary.key,
                                e.id,
                              ),
                            ),
                          ),
                        );
                      })
                      .toList()
                      .toWrap(spacing: 12.0, runSpacing: 8.0),

                  const SizedBox(height: 1, width: double.maxFinite),
                ].toColumn(
                  crossAxisAlignment: .start,
                  separator: const SizedBox(height: 8.0),
                );

            final poster =
                [
                      if (args.summary.thumbUrl != null)
                        Image.network(
                          args.summary.thumbUrl!,
                          fit: .contain,
                        ).positioned(left: 0, right: 0),
                      if (snapshot.hasData || item.thumbUrl != null)
                        Image.network(
                          item.thumbUrl!,
                          fit: .contain,
                        ).positioned(left: 0, right: 0),
                    ]
                    .toStack()
                    .constrained(width: 240, maxHeight: 500)
                    .clipRRect(all: 12);

            return [
              header,
              [
                Skeletonizer(
                  enabled: !snapshot.hasData,
                  child: info,
                ).padding(left: 12.0).constrained(maxWidth: 600).flexible(),
                poster.hero(tag: '${args.linkerId}/${args.summary.key}'),
              ].toRow(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                separator: const SizedBox(width: 16.0),
              ),
            ].toColumn(
              crossAxisAlignment: .stretch,
              separator: const SizedBox(height: 12.0),
            );
          },
        )
        .scrollable(padding: EdgeInsets.all(16.0))
        .backgroundColor(theme.colorScheme.surface);
  }

  Map<String, double> _getEpProgress(
    BuildContext context,
    _DetailPageArg args,
    List<Episode> episodes,
  ) {
    final result = <String, double>{};

    final history = context.read<History>();

    for (final ep in episodes) {
      final recordId = GalleryParser.getRecordId(
        linkerId: args.linkerId,
        mediaKey: args.summary.key,
        epId: ep.id,
      );

      final progress = history[recordId]?.progress;
      if (progress != null) {
        result[ep.id] = progress.ratio;
      }
    }
    return result;
  }

  Widget _createPlayButton(
    BuildContext context,
    _DetailPageArg args,
    List<Episode> episodes,
    Map<String, double> epProgress,
  ) {
    late final String epId;
    late final String text;

    if (epProgress.isEmpty) {
      epId = episodes.first.id;
      text = '开始观看 ${episodes.first.title}';
    } else {
      final lastProgress = epProgress.values.last;
      final lastId = epProgress.keys.last;
      final lastIndex = episodes.indexWhere((e) => e.id == lastId);
      if (lastProgress < 0.9) {
        epId = epProgress.keys.last;
        text = '继续观看 ${episodes[lastIndex].title} (已看${lastProgress.toLevel}%)';
      } else {
        if (lastIndex < episodes.length - 1) {
          epId = episodes[lastIndex + 1].id;
          text = '继续观看 ${episodes[lastIndex + 1].title}';
        } else {
          epId = episodes.first.id;
          text = '重新观看 ${episodes.first.title}';
        }
      }
    }

    return FilledButton(
      onPressed: Actions.handler(
        context,
        SelectUrlIntent(
          gallery.createUrl(args.linkerId, args.summary.key, epId),
        ),
      ),
      child: Text(text),
    );
  }

  TableRow? _createRow(BuildContext context, String label, dynamic value) {
    if (value == null) return null;

    final theme = Theme.of(context);
    return TableRow(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ).padding(right: 24.0, bottom: 12.0),
        SelectableText(
          switch (value) {
            String _ => value,
            List<String> _ => value.join(' / '),
            _ => '',
          },
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.5,
          ),
        ).padding(bottom: 12.0),
      ],
    );
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
