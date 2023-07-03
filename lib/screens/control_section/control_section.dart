import 'package:bunga_player/screens/control_section/video_open_control.dart';
import 'package:bunga_player/screens/control_section/call_control.dart';
import 'package:bunga_player/screens/control_section/login_control.dart';
import 'package:bunga_player/screens/control_section/main_control.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/control_section/subtitle_control.dart';
import 'package:bunga_player/screens/control_section/tune_control.dart';
import 'package:bunga_player/screens/control_section/welcome_control.dart';
import 'package:bunga_player/screens/progress_section/video_progress_indicator.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:bunga_player/services/voice_call.dart';
import 'package:flutter/material.dart';

enum ControlUIState {
  login,
  welcome,
  main,
  call,
  popmoji,
  subtitle,
  tune,
  open,
}

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

    UINotifiers().isUIHidden.addListener(_onUIHiddenChanged);
    VoiceCall().callStatusNotifier.addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    UINotifiers().isUIHidden.removeListener(_onUIHiddenChanged);
    VoiceCall().callStatusNotifier.removeListener(_onCallStatusChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Navigator(
      initialRoute: 'control:login',
      key: _navigatorStateKey,
      onGenerateRoute: (settings) {
        final arguments = settings.arguments as Map<String, dynamic>?;
        final routes = {
          'control:login': LoginControl(
            previousName: arguments?['previousName'] as String?,
          ),
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
    if (VoiceCall().callStatusNotifier.value == CallStatus.callIn) {
      final navigator = _navigatorStateKey.currentState!;
      navigator.popUntil((route) => route.settings.name == 'control:main');
      navigator.pushNamed('control:call');
    }
  }

  void _onUIHiddenChanged() {
    // When show again during fullscreen, route to main control
    if (UINotifiers().isUIHidden.value == false &&
        // Avoid change login control to main control
        !VideoPlayer().isStoppedNotifier.value) {
      final navigator = _navigatorStateKey.currentState!;
      navigator.popUntil((route) => route.settings.name == 'control:main');
    }
  }
}

class _ControlRoute<T> extends MaterialPageRoute<T> {
  _ControlRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
  }) : super(builder: builder, settings: settings);

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
