import 'package:flutter/material.dart';

void runAfterBuild(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
