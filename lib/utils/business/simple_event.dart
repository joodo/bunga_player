import 'package:flutter/foundation.dart';

class SimpleEvent extends ChangeNotifier {
  void fire() => notifyListeners();
}
