import 'package:animations/animations.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:bunga_player/bunga_server/models/channel_tokens.dart';

import 'alist.dart';
import 'gallery.dart';
import 'history.dart';

typedef OpenVideoDialogResult = ({Uri url, bool onlyForMe});

class SwitchTabIntent extends Intent {
  final int index;
  const SwitchTabIntent({required this.index});
}

class OpenVideoDialog extends StatefulWidget {
  final bool forceShareToChannel;
  const OpenVideoDialog({super.key, this.forceShareToChannel = false});

  @override
  State<OpenVideoDialog> createState() => _OpenVideoDialogState();
}

class _OpenVideoDialogState extends State<OpenVideoDialog> {
  @override
  Widget build(BuildContext context) {
    final content = Consumer<DialogShareModeNotifier>(
      builder: (context, shareModeNotifier, child) {
        final theme = Theme.of(context);

        final headerContent = [
          const TabBar(
            tabAlignment: .start,
            isScrollable: true,
            indicatorSize: .label,
            dividerHeight: 0,
            tabs: <Widget>[
              Tab(text: '网络媒体', icon: Icon(Icons.video_library)),
              Tab(text: '网盘', icon: Icon(Icons.cloud_outlined)),
              Tab(text: '历史', icon: Icon(Icons.history)),
            ],
          ).flexible(fit: .tight),
          widget.forceShareToChannel
              ? const Text(
                  '视频将分享到频道',
                ).textStyle(Theme.of(context).textTheme.labelMedium!)
              : SegmentedButton(
                  segments: [
                    const ButtonSegment(label: Text('自己观看'), value: false),
                    const ButtonSegment(label: Text('分享到频道'), value: true),
                  ],
                  selected: {shareModeNotifier.value},
                  onSelectionChanged: (values) =>
                      shareModeNotifier.value = values.first,
                ).constrained(width: 250.0),
          CloseButton(),
        ].toRow(separator: const SizedBox(width: 12.0));
        final header = AnimatedTheme(
          data: widget.forceShareToChannel || shareModeNotifier.value
              ? theme
              : theme.copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: theme.colorScheme.tertiary,
                    brightness: theme.brightness,
                  ),
                ),
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 300),
          child: headerContent,
        );

        final aListEnabled = context.read<ChannelTokens?>()?.alist != null;
        final body = _SharedAxisTabView(
          children: <Widget>[
            const GalleryTab().colorScheme(
              seedColor: Colors.blue,
              brightness: theme.brightness,
            ),
            aListEnabled
                ? const AListTab().colorScheme(
                    seedColor: Colors.red,
                    brightness: theme.brightness,
                  )
                : const Text(
                    '网盘服务不可用，请到控制台设置',
                  ).textStyle(theme.textTheme.labelLarge!),
            const HistoryTab(),
          ],
        );

        return [
          header.padding(horizontal: 16.0),
          Divider(color: theme.tabBarTheme.dividerColor, height: 1.0),
          body.expanded(),
        ].toColumn().actions(
          actions: {
            SelectUrlIntent: _SelectUrlAction(
              dialogContext: context,
              onlyForMe: !shareModeNotifier.value,
            ),
            SwitchTabIntent: CallbackAction<SwitchTabIntent>(
              onInvoke: (intent) =>
                  DefaultTabController.of(context).index = intent.index,
            ),
          },
        );
      },
    );

    return DefaultTabController(length: 3, child: content);
  }
}

class SelectUrlIntent extends Intent {
  final Uri url;
  const SelectUrlIntent(this.url);
}

class _SelectUrlAction extends Action<SelectUrlIntent> {
  final bool onlyForMe;
  final BuildContext dialogContext;
  _SelectUrlAction({required this.onlyForMe, required this.dialogContext});

  @override
  void invoke(SelectUrlIntent intent) {
    Navigator.of(
      dialogContext,
    ).pop<OpenVideoDialogResult>((url: intent.url, onlyForMe: onlyForMe));
  }
}

class _SharedAxisTabView extends StatefulWidget {
  final List<Widget> children;

  const _SharedAxisTabView({required this.children});

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
