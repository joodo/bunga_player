import 'package:bunga_player/play/actions.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/screens/control_section/danmaku_control.dart';
import 'package:bunga_player/screens/control_section/source_selection_control.dart';
import 'package:bunga_player/screens/control_section/rename_control.dart';
import 'package:bunga_player/screens/player_screen/player/video_control.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/control_section/tune_control.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class ControlSection extends StatefulWidget {
  const ControlSection({super.key});
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class LockObserver extends RouteObserver {
  final ShouldShowHUD showHud;
  LockObserver(this.showHud);

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute?.settings.name == 'control:main') {
      showHud.unlock('not main control');
    } else {
      showHud.lockUp('not main control');
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == 'control:main') {
      showHud.unlock('not main control');
    } else {
      showHud.lockUp('not main control');
    }
    super.didPush(route, previousRoute);
  }
}

class _ControlSectionState extends State<ControlSection> {
  final _navigatorStateKey = GlobalKey<NavigatorState>();
  late final _showHUD = context.read<ShouldShowHUD>();

  late final _routeObserver = LockObserver(_showHUD);

  @override
  void initState() {
    super.initState();

    _showHUD.addListener(_onUIHiddenChanged);
  }

  @override
  void dispose() {
    _showHUD.removeListener(_onUIHiddenChanged);

    super.dispose();
  }

  Widget buildByName(String name) {
    return switch (name) {
      'control:rename' => const RenameControl(),
      'control:main' => const VideoControl(),
      'control:popmoji' => const PopmojiControl(),
      'control:tune' => const TuneControl(),
      'control:danmaku' => const DanmakuControl(),
      'control:source_selection' => const SourceSelectionControl(),
      String() => throw Exception('Invalid route: $name'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final name = context.read<ClientNicknameNotifier>().value;
    final initialRouteName =
        'control:${name.isNotEmpty ? 'welcome' : 'rename'}';

    final navigator = Navigator(
      initialRoute: initialRouteName,
      key: _navigatorStateKey,
      observers: [_routeObserver],
      onGenerateRoute: (settings) {
        return PageRouteBuilder<void>(
          pageBuilder: (context, _, __) => GestureDetector(
            onTap: () {},
            onDoubleTap: () {},
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: buildByName(settings.name ?? 'unknown'),
            ),
          ),
          transitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurveTween(curve: Curves.easeOutCubic).animate(animation),
            child: child,
          ),
          settings: settings,
        );
      },
    );

    return _ShortcutsWrapper(child: navigator);
  }

  void _onCallStatusChanged() {}

  void _onUIHiddenChanged() {
    // When show again during fullscreen, route to main control
    if (context.read<ShouldShowHUD>().value == false &&
        // Avoid change login control to main control
        context.read<PlayStatus>() != PlayStatus.stop) {
      final navigator = _navigatorStateKey.currentState!;
      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (mounted) {
            navigator
                .popUntil((route) => route.settings.name == 'control:main');
          }
        },
      );
    }
  }
}

class _ShortcutsWrapper extends SingleChildStatelessWidget {
  const _ShortcutsWrapper({super.child});

  static const _intentMapping = <ShortcutKey, Intent>{
    ShortcutKey.volumeUp: SetVolumeIntent.increase(10),
    ShortcutKey.volumeDown: SetVolumeIntent.increase(-10),
    ShortcutKey.forward5Sec: SeekIntent.increase(Duration(seconds: 5)),
    ShortcutKey.backward5Sec: SeekIntent.increase(Duration(seconds: -5)),
    ShortcutKey.togglePlay: TogglePlayIntent(),
    ShortcutKey.screenshot: ScreenshotIntent(),
  };

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Consumer<ShortcutMappingNotifier>(
      builder: (context, shortcutMapping, child) => Shortcuts(
        shortcuts: (_intentMapping.map((shortcutKey, intent) =>
                MapEntry(shortcutMapping.value[shortcutKey], intent))
              ..remove(null))
            .map((key, value) => MapEntry(key!, value)),
        child: child!,
      ),
      child: child,
    );
  }
}
