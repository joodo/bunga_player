import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/extensions/styled_widget.dart';

extension BlurToastExtension on Widget {
  Widget blurToast() => Theme(
    data: ThemeData.light(),
    child: material(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      color: Colors.white54,
    ).backgroundBlur(10.0).clipRRect(all: 100.0),
  );
}
