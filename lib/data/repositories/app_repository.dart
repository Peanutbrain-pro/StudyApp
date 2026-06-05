import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyapp/constants.dart';
import 'package:studyapp/data/database/app_database.dart';

enum AppInitStatus { firstLaunch, ready }

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
    if (firstLaunch == null || firstLaunch == true) {
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
    // Can't remove all the app settings like save location when resetting settings
    final String saveLocation = _prefs.getString(keySaveLocation)!;
    _prefs.clear();
    _prefs.setString(keySaveLocation, saveLocation);
    _prefs.setBool(keyFirstLaunch, false);
  }

  void completeHardReset() {
    print("Completely deleting everything in the app. No setting no databases");
    _prefs.clear();
  }

  // void closeApp() {
  //   windowManager.destroy();
  // }

  Future<AppDatabase> getAppDatabase() async {
    final saveLocation = getSaveLocation();
    return AppDatabase(saveLocation!);
  }
}
