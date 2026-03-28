import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/constants.dart';

enum AppInitStatus {
  firstLaunch, ready
}

class AppRepository {
  final SharedPreferences _prefs;
  AppRepository(this._prefs);
  
  Future<void> removeFirstLaunch() async {
    await _prefs.setBool(keyFirstLaunch, false);
  }

  Future<String?> getSaveLocation() async {
    return await _prefs.getString(keySaveLocation);
  }

  Future<AppInitStatus> getAppStatus() async {
    final bool? firstLaunch = _prefs.getBool(keyFirstLaunch);
    if (firstLaunch == null || firstLaunch == 'true') {
      _prefs.setBool(keyFirstLaunch, true);
      return AppInitStatus.firstLaunch;
    }

    final String? saveLocation = _prefs.getString(keySaveLocation);
    if (saveLocation == null) {
      throw Exception("saveLocation is missing.");
    } else {
      return AppInitStatus.ready;
    }
  }

  Future<void> setSaveLocation(String saveLocation) async {
    await _prefs.setString(keySaveLocation, saveLocation);
  }

  Future<void> clearAppSettings() async {
    await _prefs.clear();
  }
}