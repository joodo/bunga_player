import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

extension BlurChipExtension on Widget {
  Widget blurChip() => backgroundColor(
    Colors.black45,
  ).backgroundBlur(10.0).clipRRect(all: 100.0);
}
