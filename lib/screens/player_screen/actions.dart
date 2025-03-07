import 'package:flutter/material.dart';

import 'panel/panel.dart';

@immutable
class ShowPanelIntent extends Intent {
  final Panel Function(BuildContext context) builder;
  const ShowPanelIntent({required this.builder});
}

class ShowPanelAction extends ContextAction<ShowPanelIntent> {
  final ValueNotifier<Panel?> widgetNotifier;
  ShowPanelAction({required this.widgetNotifier});

  @override
  Future<void> invoke(ShowPanelIntent intent, [BuildContext? context]) async {
    widgetNotifier.value = intent.builder(context!);
  }
}

@immutable
class ClosePanelIntent extends Intent {}

class ClosePanelAction extends ContextAction<ClosePanelIntent> {
  final ValueNotifier<Widget?> widgetNotifier;
  ClosePanelAction({required this.widgetNotifier});

  @override
  Future<void> invoke(ClosePanelIntent intent, [BuildContext? context]) async {
    widgetNotifier.value = null;
  }
}

@immutable
class ToggleDanmakuControlIntent extends Intent {
  final bool? show;
  const ToggleDanmakuControlIntent({this.show});
}

class ToggleDanmakuControlAction
    extends ContextAction<ToggleDanmakuControlIntent> {
  final ValueNotifier<bool> showDanmakuControlNotifier;
  ToggleDanmakuControlAction({required this.showDanmakuControlNotifier});

  @override
  void invoke(
    ToggleDanmakuControlIntent intent, [
    BuildContext? context,
  ]) {
    showDanmakuControlNotifier.value =
        intent.show ?? !showDanmakuControlNotifier.value;
  }
}
