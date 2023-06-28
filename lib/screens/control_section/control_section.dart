import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/screens/control_section/video_open_control.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/screens/control_section/call_control.dart';
import 'package:bunga_player/screens/control_section/login_control.dart';
import 'package:bunga_player/screens/control_section/main_control.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/control_section/subtitle_control.dart';
import 'package:bunga_player/screens/control_section/tune_control.dart';
import 'package:bunga_player/screens/control_section/welcome_control.dart';
import 'package:bunga_player/screens/player_section/video_progress_widget.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_controller.dart';
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
  final _callRinger = AudioPlayer()..setSource(AssetSource('sounds/call.wav'));
  late BuildContext _navigatorContext;

  @override
  void initState() {
    super.initState();

    UINotifiers().isUIHidden.addListener(_onUIHiddenChanged);
    IMController().callStatus.addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    UINotifiers().isUIHidden.removeListener(_onUIHiddenChanged);
    IMController().callStatus.removeListener(_onCallStatusChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'control:login',
      onGenerateRoute: (settings) {
        final routes = {
          'control:login': const LoginControl(),
          'control:welcome': const WelcomeControl(),
          'control:main': const MainControl(),
          'control:call': const CallControl(),
          'control:popmoji': const PopmojiControl(),
          'control:subtitle': const SubtitleControl(),
          'control:tune': const TuneControl(),
          'control:open': const VideoOpenControl(),
        };

        Widget? body = routes[settings.name];
        if (body == null) throw Exception('Invalid route: ${settings.name}');

        body = Container(
          color: Theme.of(context).colorScheme.surface,
          child: body,
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

        return _ControlRoute<void>(
          builder: (BuildContext context) {
            _navigatorContext = context;
            return body!;
          },
          settings: settings,
        );
      },
    );
  }

  void _onCallStatusChanged() {
    final callStatus = IMController().callStatus.value;

    // Control section UI
    final currentControl = _navigatorContext.mounted
        ? ModalRoute.of(_navigatorContext)?.settings.name
        : null;
    switch (callStatus) {
      case CallStatus.none:
        if (currentControl == 'control:call') {
          Navigator.of(_navigatorContext).pop();
        }
        break;
      case CallStatus.callIn:
        Navigator.of(_navigatorContext)
            .popUntil((route) => route.settings.name == 'control:main');
        Navigator.of(_navigatorContext).pushNamed('control:call');
        break;
      default:
        {}
    }

    // Play sound when call in or out
    if (callStatus == CallStatus.callIn || callStatus == CallStatus.callOut) {
      _callRinger.resume();
    } else {
      _callRinger.stop();
    }
  }

  void _onUIHiddenChanged() {
    // When show again
    if (UINotifiers().isUIHidden.value == false &&
        // Avoid change login control to main control
        !VideoController().isStopped.value) {
      Navigator.of(_navigatorContext)
          .popUntil((route) => route.settings.name == 'control:main');
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
