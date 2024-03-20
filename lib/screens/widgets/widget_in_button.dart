import 'package:flutter/material.dart';

Widget createIndicatorInButton(BuildContext context) {
  final textStyle = DefaultTextStyle.of(context).style;
  return SizedBox.square(
    dimension: textStyle.fontSize,
    child: CircularProgressIndicator(
      color: textStyle.color,
      strokeWidth: 2,
    ),
  );
}

Widget createIconInButton(
  BuildContext context,
  IconData data, {
  Color? color,
}) {
  final textStyle = DefaultTextStyle.of(context).style;
  return Icon(
    data,
    color: color,
    size: textStyle.fontSize,
  );
}
