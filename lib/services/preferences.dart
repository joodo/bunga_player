import 'package:bunga_player/services/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences _pref;
  Preferences(this._pref);
  static Future<Preferences> create() async {
    return Preferences(await SharedPreferences.getInstance());
  }

  Future<bool> set(String key, dynamic value) async {
    final Future<bool> result;
    switch (value.runtimeType) {
      case const (bool):
        result = _pref.setBool(key, value);
      case const (double):
        result = _pref.setDouble(key, value);
      case const (int):
        result = _pref.setInt(key, value);
      case const (String):
        result = _pref.setString(key, value);
      case const (List<String>):
        result = _pref.setStringList(key, value);
      case const (Null):
        result = _pref.remove(key);
      default:
        throw 'Unsupport value type: ${value.runtimeType}';
    }

    result.then((success) {
      if (success) {
        logger.i('Preference: set $key=$value');
      } else {
        logger.w('Preference: failed to set $key=$value');
      }
    });
    return result;
  }

  Future<bool> remove(String key) {
    logger.i('Preference: remove $key');
    return _pref.remove(key);
  }

  Future<void> reload() => _pref.reload();

  Set<String> get keys => _pref.getKeys();

  T? get<T>(String key) {
    switch (T) {
      case const (bool):
        return _pref.getBool(key) as T?;
      case const (double):
        return _pref.getDouble(key) as T?;
      case const (int):
        return _pref.getInt(key) as T?;
      case const (String):
        return _pref.getString(key) as T?;
      case const (List<String>):
        return _pref.getStringList(key) as T?;
      default:
        return _pref.get(key) as T?;
    }
  }

  T getOrCreate<T>(String key, T defaultValue) {
    if (_pref.containsKey(key)) {
      return get<T>(key)!;
    } else {
      set(key, defaultValue);
      return defaultValue;
    }
  }
}

extension BindPreference<R> on ValueNotifier<R> {
  void bindPreference<T>({
    required Preferences preferences,
    required String key,
    required R Function(T pref) load,
    required T? Function(R value) update,
  }) {
    addListener(() {
      preferences.set(key, update(value));
    });

    final pref = preferences.get<T>(key);
    if (pref != null) {
      value = load(pref);
    } else {
      preferences.set(key, update(value));
    }
  }
}
