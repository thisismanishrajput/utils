import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferencesManager? _instance;
  static SharedPreferences? _sharedPreferences;

  static const String accessToken = 'accessToken';
  static const String secretAccessToken = 'secretAccessToken';
  static const String refreshToken = 'refreshToken';
  static const String expiryTimeAccessToken = 'accessExpiry';
  static const String expiryTimeRefreshToken = 'refreshExpiry';
  

  static Future<SharedPreferencesManager?> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesManager();
    }
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _instance;
  }

  Future<bool> putString(String key, String value) =>
      _sharedPreferences!.setString(key, value);

  String? getString(String key) => _sharedPreferences!.getString(key);

  Future<bool> clearKey(String key) => _sharedPreferences!.remove(key);
}
