import 'package:flutter/widgets.dart';

import 'play.dart' as play;

final actionBindings = <Type, Action<Intent>>{
  ...play.bindings,
};
