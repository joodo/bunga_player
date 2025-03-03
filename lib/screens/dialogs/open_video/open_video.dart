import 'package:animations/animations.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/extensions/styled_widget.dart';

import 'alist.dart';
import 'direct_link.dart';
import 'history.dart';

typedef OpenVideoDialogResult = ({Uri url, bool onlyForMe});

class OpenVideoDialog extends StatefulWidget {
  final bool forceShareToChannel;
  final bool shareToChannel;
  const OpenVideoDialog({
    super.key,
    this.shareToChannel = true,
    this.forceShareToChannel = false,
  });

  @override
  State<OpenVideoDialog> createState() => _OpenVideoDialogState();
}

class _OpenVideoDialogState extends State<OpenVideoDialog> {
  late bool _onlyForMe = !widget.shareToChannel;

  @override
  Widget build(BuildContext context) {
    final aListEnabled = context.read<BungaClientInfo?>()?.alist != null;
    final theme = Theme.of(context);
    final body = [
      [
        StyledWidget(IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )).alignment(Alignment.centerLeft),
        const TabBar(
          tabAlignment: TabAlignment.center,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          tabs: <Widget>[
            Tab(text: '网络链接', icon: Icon(Icons.link)),
            Tab(text: '　网盘　', icon: Icon(Icons.cloud_outlined)),
            Tab(text: '　历史　', icon: Icon(Icons.history)),
          ],
        ),
        (widget.forceShareToChannel
                ? const Text('视频将分享到频道')
                    .textStyle(Theme.of(context).textTheme.labelMedium!)
                : FilledButton(
                    onPressed: () {
                      setState(() {
                        _onlyForMe = !_onlyForMe;
                      });
                    },
                    child: Text(_onlyForMe ? '自己观看' : '分享到频道'),
                  ))
            .alignment(Alignment.centerRight),
      ].toStack(alignment: Alignment.center).padding(horizontal: 16.0),
      Divider(
        color: theme.tabBarTheme.dividerColor,
        height: 1.0,
      ),
      _SharedAxisTabView(
        children: <Widget>[
          const DirectLinkTab().colorScheme(seedColor: Colors.blue),
          aListEnabled
              ? const AListTab().colorScheme(seedColor: Colors.red)
              : const Text('网盘服务不可用，请到控制台设置')
                  .textStyle(theme.textTheme.labelLarge!),
          const HistoryTab(),
        ],
      ).expanded(),
    ].toColumn().actions(actions: {
      SelectUrlIntent: _SelectUrlAction(onlyForMe: _onlyForMe),
    });

    return DefaultTabController(length: 3, child: body);
  }
}

class SelectUrlIntent extends Intent {
  final Uri url;
  const SelectUrlIntent(this.url);
}

class _SelectUrlAction extends ContextAction<SelectUrlIntent> {
  final bool onlyForMe;
  _SelectUrlAction({required this.onlyForMe});

  @override
  Future<void> invoke(SelectUrlIntent intent, [BuildContext? context]) async {
    Navigator.pop<OpenVideoDialogResult>(
      context!,
      (url: intent.url, onlyForMe: onlyForMe),
    );
  }
}

class _SharedAxisTabView extends StatefulWidget {
  final List<Widget> children;

  const _SharedAxisTabView({
    // ignore: unused_element_parameter
    super.key,
    required this.children,
  });

  @override
  State<_SharedAxisTabView> createState() => _SharedAxisTabViewState();
}

class _SharedAxisTabViewState extends State<_SharedAxisTabView> {
  late final _controller = DefaultTabController.of(context);

  int _currentIndex = 0;
  bool _reverse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(_onTabChanged);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: _controller.animationDuration,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      reverse: _reverse,
      child: KeyedSubtree(
        key: ValueKey<int>(_currentIndex),
        child: widget.children[_currentIndex],
      ),
    );
  }

  void _onTabChanged() {
    if (_controller.index != _currentIndex) {
      setState(() {
        _reverse = _currentIndex > _controller.index;
        _currentIndex = _controller.index;
      });
    }
  }
}
