import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/common/fullscreen.dart';
import 'package:bunga_player/common/im_controller.dart';
import 'package:bunga_player/screens/control_section/call_control.dart';
import 'package:bunga_player/screens/control_section/indexed_stack_item.dart';
import 'package:bunga_player/screens/control_section/login_control.dart';
import 'package:bunga_player/screens/control_section/main_control.dart';
import 'package:bunga_player/screens/control_section/popmoji_control.dart';
import 'package:bunga_player/screens/control_section/subtitle_control.dart';
import 'package:bunga_player/screens/control_section/tune_control.dart';
import 'package:bunga_player/screens/control_section/welcome_control.dart';
import 'package:bunga_player/screens/player_section/video_progress_widget.dart';
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
}

class ControlSection extends StatefulWidget {
  final ValueNotifier<bool> isUIHiddenNotifier;
  final ValueNotifier<bool> isBusyNotifier;
  final ValueNotifier<String?> hintTextNotifier;
  const ControlSection({
    super.key,
    required this.isUIHiddenNotifier,
    required this.isBusyNotifier,
    required this.hintTextNotifier,
  });
  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  late final _controls = <Widget>[
    LoginControl(
      isBusyNotifier: widget.isBusyNotifier,
      hintTextNotifier: widget.hintTextNotifier,
      onLoginSuccess: () => setState(() {
        _uiState = ControlUIState.welcome;
      }),
    ),
    WelcomeControl(
      isBusyNotifier: widget.isBusyNotifier,
      hintTextNotifier: widget.hintTextNotifier,
      onLoadSuccessed: () => setState(() {
        _uiState = ControlUIState.main;
      }),
      onLoggedOut: () => setState(() {
        _uiState = ControlUIState.login;
      }),
    ),
    MainControl(
      isBusyNotifier: widget.isBusyNotifier,
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

    widget.isUIHiddenNotifier.addListener(_onUIHiddenChanged);
    FullScreen().notifier.addListener(_onFullScreenChanged);
    IMController().callStatus.addListener(_onCallStatusChanged);
  }

  @override
  void dispose() {
    widget.isUIHiddenNotifier.removeListener(_onUIHiddenChanged);
    IMController().callStatus.removeListener(_onCallStatusChanged);
    FullScreen().notifier.removeListener(_onFullScreenChanged);

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
    if (widget.isUIHiddenNotifier.value == false &&
        widget.hintTextNotifier.value == null) {
      setState(() {
        _uiState = ControlUIState.main;
      });
    }
  }

  void _onFullScreenChanged() async {
    // HACK: exit full screen makes layout a mass in Windows
    if (FullScreen().notifier.value == false) {
      var size = await windowManager.getSize();
      size += const Offset(1, 1);
      windowManager.setSize(size);
    }
  }
}
