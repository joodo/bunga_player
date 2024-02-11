import 'package:flutter/widgets.dart';

import 'chat.dart' as chat;
import 'play.dart' as play;

final actionBindings = <Type, Action<Intent>>{
  ...chat.bindings,
  ...play.bindings,
};
