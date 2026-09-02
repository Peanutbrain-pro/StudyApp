import 'dart:io';
import 'package:flutter/foundation.dart';
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
    final String? saveLocation = _prefs.getString(keySaveLocation);

    // If firstLaunch flag is true/unset, or saveLocation is missing or was deleted from disk
    if (firstLaunch == null || firstLaunch == true || saveLocation == null || !Directory(saveLocation).existsSync()) {
      _prefs.setBool(keyFirstLaunch, true);
      return AppInitStatus.firstLaunch;
    }

    return AppInitStatus.ready;
  }

  void setSaveLocation(String saveLocation) {
    _prefs.setString(keySaveLocation, saveLocation);
  }

  String getAppFont() {
    return _prefs.getString(keyAppFont) ?? 'System Default';
  }

  Future<void> setAppFont(String font) async {
    await _prefs.setString(keyAppFont, font);
  }

  String getEditorFont() {
    return _prefs.getString(keyEditorFont) ?? 'System Default';
  }

  Future<void> setEditorFont(String font) async {
    await _prefs.setString(keyEditorFont, font);
  }

  void clearAppSettings() {
    // Can't remove all the app settings like save location when resetting settings
    final String saveLocation = _prefs.getString(keySaveLocation)!;
    _prefs.clear();
    _prefs.setString(keySaveLocation, saveLocation);
    _prefs.setBool(keyFirstLaunch, false);
  }

  void completeHardReset() {
    debugPrint("Completely deleting everything in the app. No setting no databases");
    _prefs.clear();
  }

  Future<AppDatabase> getAppDatabase() async {
    final saveLocation = getSaveLocation();
    return AppDatabase(saveLocation!);
  }
}
