import 'package:bunga_player/services/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences(this._pref);
  final SharedPreferences _pref;
  static Future<Preferences> create() async {
    return Preferences(await SharedPreferences.getInstance());
  }

  Future<bool> set(String key, dynamic value) async {
    final Future<bool> result;
    switch (value.runtimeType) {
      case bool:
        result = _pref.setBool(key, value);
        break;
      case double:
        result = _pref.setDouble(key, value);
        break;
      case int:
        result = _pref.setInt(key, value);
        break;
      case String:
        result = _pref.setString(key, value);
        break;
      case List<String>:
        result = _pref.setStringList(key, value);
        break;
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
      case bool:
        return _pref.getBool(key) as T?;
      case double:
        return _pref.getDouble(key) as T?;
      case int:
        return _pref.getInt(key) as T?;
      case String:
        return _pref.getString(key) as T?;
      case List<String>:
        return _pref.getStringList(key) as T?;
      default:
        return _pref.get(key) as T?;
    }
  }
}
