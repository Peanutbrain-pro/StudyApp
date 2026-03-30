import 'package:drift_flutter/drift_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/constants.dart';
import 'package:studyapp/data/database/app_database.dart';

enum AppInitStatus {
  firstLaunch, ready
}

class AppRepository {
  final SharedPreferences _prefs;
  AppRepository(this._prefs);

  void removeFirstLaunch() async {
    _prefs.setBool(keyFirstLaunch, false);
  }

  String? getSaveLocation() {
    return _prefs.getString(keySaveLocation);
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

  void setSaveLocation(String saveLocation) {
    _prefs.setString(keySaveLocation, saveLocation);
  }

  void clearAppSettings() {
    _prefs.clear();
  }

  Future<AppDatabase> getAppDatabase() async {
    final saveLocation = await getSaveLocation();
    return AppDatabase(saveLocation!);
  }
}