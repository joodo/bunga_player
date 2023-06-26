import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/screens/control_section/video_open_control.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/screens/control_section/call_control.dart';
import 'package:bunga_player/screens/control_section/indexed_stack_item.dart';
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
import 'package:window_manager/window_manager.dart';

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
  late final _controls = <Widget>[
    LoginControl(
      onLoginSuccess: () => setState(() {
        _uiState = ControlUIState.welcome;
      }),
    ),
    WelcomeControl(
      onLoadSuccessed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
      onLoggedOut: () => setState(() {
        _uiState = ControlUIState.login;
      }),
    ),
    MainControl(
      onStateButtonPressed: (stateString) => setState(() {
        _uiState = ControlUIState.values
            .firstWhere((e) => e.toString().split('.').last == stateString);
      }),
    ),
    CallControl(
      onBackPressed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
    ),
    PopmojiControl(
      onBackPressed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
    ),
    SubtitleControl(
      onBackPressed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
    ),
    TuneControl(
      onBackPressed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
    ),
    VideoOpenControl(
      onBackPressed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
      onLoadSuccessed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
    ),
  ];

  var __uiState = ControlUIState.login;
  ControlUIState get _uiState => __uiState;
  set _uiState(ControlUIState newState) {
    final oldItem = _controls[__uiState.index];
    if (oldItem is IndexedStackItem) {
      (oldItem as IndexedStackItem).onLeave();
    }

    __uiState = newState;
    final newItem = _controls[__uiState.index];
    if (newItem is IndexedStackItem) {
      (newItem as IndexedStackItem).onEnter();
    }
  }

  final _callRinger = AudioPlayer()..setSource(AssetSource('sounds/call.wav'));

  @override
  void initState() {
    super.initState();

    UINotifiers().isUIHidden.addListener(_onUIHiddenChanged);
    UINotifiers().isFullScreen.addListener(_onFullScreenChanged);
    IMController().callStatus.addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    UINotifiers().isUIHidden.removeListener(_onUIHiddenChanged);
    IMController().callStatus.removeListener(_onCallStatusChanged);
    UINotifiers().isFullScreen.removeListener(_onFullScreenChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = IndexedStack(
      sizing: StackFit.expand,
      index: _uiState.index,
      children: _controls,
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

    return body;
  }

  void _onCallStatusChanged() {
    final callStatus = IMController().callStatus.value;

    // Control section UI
    switch (callStatus) {
      case CallStatus.none:
        if (_uiState == ControlUIState.call) {
          setState(() {
            _uiState = ControlUIState.main;
          });
        }
        break;
      case CallStatus.callIn:
        setState(() {
          _uiState = ControlUIState.call;
        });
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
      setState(() {
        _uiState = ControlUIState.main;
      });
    }
  }

  void _onFullScreenChanged() async {
    // HACK: exit full screen makes layout a mass in Windows
    if (UINotifiers().isFullScreen.value == false) {
      var size = await windowManager.getSize();
      size += const Offset(1, 1);
      windowManager.setSize(size);
    }
  }
}
