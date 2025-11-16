import 'dart:io';

bool get disabledUpdateCheck {
  if (Platform.isIOS) return true;

  return false;
}
