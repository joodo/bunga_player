import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension SingleActivatorSerialize on SingleActivator {
  String serialize() {
    return '${trigger.keyId},$meta,$control,$alt,$shift';
  }
}

SingleActivator unserializeSingleActivator(String data) {
  final splits = data.split(',');
  return SingleActivator(
    LogicalKeyboardKey(int.parse(splits[0])),
    meta: bool.parse(splits[1]),
    control: bool.parse(splits[2]),
    alt: bool.parse(splits[3]),
    shift: bool.parse(splits[4]),
  );
}
