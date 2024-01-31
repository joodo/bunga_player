import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/providers/states/voice_call.dart';
import 'package:bunga_player/screens/control_section/video_open_control.dart';
import 'package:bunga_player/screens/control_section/call_control.dart';
import 'package:bunga_player/screens/control_section/rename_control.dart';
import 'package:bunga_player/screens/control_section/main_control.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/control_section/subtitle_control.dart';
import 'package:bunga_player/screens/control_section/tune_control.dart';
import 'package:bunga_player/screens/control_section/welcome_control.dart';
import 'package:bunga_player/screens/progress_section/video_progress_indicator.dart';
import 'package:bunga_player/providers/business/video_player.dart';
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

    context.read<IsControlSectionHidden>().addListener(_onUIHiddenChanged);
    context.read<VoiceCall>().addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    context.read<IsControlSectionHidden>().removeListener(_onUIHiddenChanged);
    context.read<VoiceCall>().removeListener(_onCallStatusChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<CurrentUser>();
    final hasUserName = currentUser.name != null;
    final initialRouteName = 'control:${hasUserName ? 'welcome' : 'rename'}';

    final body = Navigator(
      initialRoute: initialRouteName,
      key: _navigatorStateKey,
      onGenerateRoute: (settings) {
        final arguments = settings.arguments as Map<String, Object?>?;
        final routes = {
          'control:rename': RenameControl(
              previousName: arguments?['previousName'] as String?),
          'control:welcome': const WelcomeControl(),
          'control:main': const MainControl(),
          'control:call': const CallControl(),
          'control:popmoji': const PopmojiControl(),
          'control:subtitle': const SubtitleControl(),
          'control:tune': const TuneControl(),
          'control:open': const VideoOpenControl(),
        };

        Widget? control = routes[settings.name];
        if (control == null) throw Exception('Invalid route: ${settings.name}');

        //context.read<UI>().changeRoute(settings.name!);
        return _ControlRoute<void>(
          builder: (BuildContext context) => Container(
            color: Theme.of(context).colorScheme.surface,
            child: control,
          ),
          settings: settings,
        );
      },
    );

    return SliderTheme(
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
  }

  void _onCallStatusChanged() {
    // Route to call control when call in
    if (context.read<VoiceCall>().callStatus == CallStatus.callIn) {
      final navigator = _navigatorStateKey.currentState!;
      navigator.pushNamed('control:call');
    }
  }

  void _onUIHiddenChanged() {
    // When show again during fullscreen, route to main control
    if (context.read<IsControlSectionHidden>().value == false &&
        // Avoid change login control to main control
        !context.read<VideoPlayer>().isStoppedNotifier.value) {
      final navigator = _navigatorStateKey.currentState!;
      navigator.popUntil((route) =>
          route.settings.name == 'control:main' ||
          route.settings.name == 'control:welcome');
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
    final a = CurveTween(curve: Curves.easeInCubic).animate(animation);
    return FadeTransition(opacity: a, child: child);
  }
}
