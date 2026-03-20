import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

extension BlurToastExtension on Widget {
  Widget blurToast() => Theme(
    data: ThemeData.light(),
    child: backgroundColor(
      Colors.white54,
    ).backgroundBlur(10.0).clipRRect(all: 100.0),
  );
}
