import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/player.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/screens/control_section/danmaku_control.dart';
import 'package:bunga_player/screens/control_section/source_selection_control.dart';
import 'package:bunga_player/screens/control_section/video_open_control.dart';
import 'package:bunga_player/screens/control_section/call_control.dart';
import 'package:bunga_player/screens/control_section/rename_control.dart';
import 'package:bunga_player/screens/control_section/main_control.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/control_section/subtitle_control.dart';
import 'package:bunga_player/screens/control_section/tune_control.dart';
import 'package:bunga_player/screens/control_section/welcome_control.dart';
import 'package:bunga_player/screens/progress_section/video_progress_indicator.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ControlSection extends StatefulWidget {
  const ControlSection({super.key});
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  final _navigatorStateKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    context.read<ShouldShowHUD>().addListener(_onUIHiddenChanged);
    context.read<CurrentCallStatus>().addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    context.read<ShouldShowHUD>().removeListener(_onUIHiddenChanged);
    context.read<CurrentCallStatus>().removeListener(_onCallStatusChanged);

    super.dispose();
  }

  Widget buildByName(String name) {
    return switch (name) {
      'control:rename' => const RenameControl(),
      'control:welcome' => const WelcomeControl(),
      'control:main' => const MainControl(),
      'control:call' => const CallControl(),
      'control:popmoji' => const PopmojiControl(),
      'control:subtitle' => const SubtitleControl(),
      'control:tune' => const TuneControl(),
      'control:open' => const VideoOpenControl(),
      'control:danmaku' => const DanmakuControl(),
      'control:source_selection' => const SourceSelectionControl(),
      String() => throw Exception('Invalid route: $name'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final pref = getIt<Preferences>();
    final name = pref.get<String>('user_name');
    final initialRouteName = 'control:${name != null ? 'welcome' : 'rename'}';

    Widget body = Navigator(
      initialRoute: initialRouteName,
      key: _navigatorStateKey,
      onGenerateRoute: (settings) {
        //context.read<UI>().changeRoute(settings.name!);
        return _ControlRoute<void>(
          builder: (BuildContext context) => Container(
            color: Theme.of(context).colorScheme.surface,
            child: buildByName(settings.name ?? 'unknown'),
          ),
          settings: settings,
        );
      },
    );

    body = SliderTheme(
      data: SliderThemeData(
        activeTrackColor: Theme.of(context).colorScheme.secondary,
        thumbColor: Theme.of(context).colorScheme.secondary,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        valueIndicatorColor: Theme.of(context).colorScheme.secondary,
        trackShape: SliderCustomTrackShape(),
        showValueIndicator: ShowValueIndicator.always,
      ),
      child: body,
    );

    return GestureDetector(
      onTap: () {},
      onDoubleTap: () {},
      child: body,
    );
  }

  void _onCallStatusChanged() {
    // Route to call control when call in
    if (context.read<CurrentCallStatus>().value == CallStatus.callIn) {
      final navigator = _navigatorStateKey.currentState!;
      navigator.pushNamed('control:call');
    }
  }

  void _onUIHiddenChanged() {
    // When show again during fullscreen, route to main control
    if (context.read<ShouldShowHUD>().value == false &&
        // Avoid change login control to main control
        context.read<PlayStatus>().value != PlayStatusType.stop) {
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

class _ControlRoute<T> extends MaterialPageRoute<T> {
  _ControlRoute({
    required super.builder,
    required RouteSettings super.settings,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final a = CurveTween(curve: Curves.easeOutCubic).animate(animation);
    return FadeTransition(opacity: a, child: child);
  }
}
