import 'dart:io';

// import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:studyapp/constants.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:path/path.dart' as p;
// import 'package:studyapp/ui/shared/utilities/dialog_helper.dart';
import 'package:window_manager/window_manager.dart';

sealed class AppState {
  // final String savePath;
  // AppState({required this.savePath});
}

class AppLoading extends AppState {
  // AppLoading({required super.savePath});
}

class AppFirstLaunch extends AppState {
  // AppFirstLaunch({required super.savePath});
}

class AppReady extends AppState {
  final bool requiresRestart;
  final String appFont;
  final String editorFont;

  AppReady({
    this.requiresRestart = false,
    this.appFont = 'System Default',
    this.editorFont = 'System Default',
  });
}

class AppCubit extends Cubit<AppState> {
  final AppRepository _appRepository;

  AppCubit({
    required AppRepository appRepository,
  })  : _appRepository = appRepository,
        super(AppLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final status = await _appRepository.getAppStatus();
    final defaultAppSaveLocation = await getDefaultAppSaveLocation();
    switch (status) {
      case AppInitStatus.firstLaunch:
        setSaveLocation(defaultAppSaveLocation);
        print("This app is launching for the first time");
        emit(AppFirstLaunch());

      case AppInitStatus.ready:
        final saveLocation = _appRepository.getSaveLocation();
        final appFont = _appRepository.getAppFont();
        final editorFont = _appRepository.getEditorFont();

        print("Save location is set to : $saveLocation");
        print("The app is ready (supposedly)");
        emit(AppReady(appFont: appFont, editorFont: editorFont));
    }
  }

  void resetSettings() {
    _appRepository.clearAppSettings();
  }

  void setDefaultFirstLaunch() async {
    final String saveLocation = await getDefaultAppSaveLocation();
    _appRepository.setSaveLocation(saveLocation);
    print("The save location is saved to the default");
    onFirstConfigFinished();
  }
  
  Future<String> getDefaultAppSaveLocation() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String saveLocation = p.join(documentsDirectory.path, appName);
    return saveLocation;
  }

  Future<void> setSaveLocation(String savePath) async {
    _appRepository.setSaveLocation(savePath);
  }

  Future<void> changeSaveLocation() async {
    String? selectedDirectoryPath = await FilePicker.getDirectoryPath();
    if (selectedDirectoryPath == null) {
      print("Directory selection canceled by user");
      return;
    }

    _appRepository.setSaveLocation(selectedDirectoryPath);
    print("Save location set to: $selectedDirectoryPath");
    emit(AppFirstLaunch());
  }

  void onFirstConfigFinished() async {
    _appRepository.removeFirstLaunch();
    final appFont = _appRepository.getAppFont();
    final editorFont = _appRepository.getEditorFont();
    emit(AppReady(appFont: appFont, editorFont: editorFont));
  }

  Future<void> closeApp() async {
    await windowManager.close();
  }

  Future<void> restartApp() async {
    final result = await Restart.restartApp();
    if (!result.success) {
      print("Couldn't restart the app");
    }
  }

  void setRequiresRestart() {
    final currentState = state;
    if (currentState is AppReady) {
      emit(AppReady(
        requiresRestart: true,
        appFont: currentState.appFont,
        editorFont: currentState.editorFont,
      ));
    } else {
      emit(AppReady(requiresRestart: true));
    }
  }

  Future<void> setAppFont(String font) async {
    await _appRepository.setAppFont(font);
    final currentState = state;
    if (currentState is AppReady) {
      emit(AppReady(
        requiresRestart: currentState.requiresRestart,
        appFont: font,
        editorFont: currentState.editorFont,
      ));
    } else {
      emit(AppReady(appFont: font));
    }
  }

  Future<void> setEditorFont(String font) async {
    await _appRepository.setEditorFont(font);
    final currentState = state;
    if (currentState is AppReady) {
      emit(AppReady(
        requiresRestart: currentState.requiresRestart,
        appFont: currentState.appFont,
        editorFont: font,
      ));
    } else {
      emit(AppReady(editorFont: font));
    }
  }
}
