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

// class AppClosing extends AppState {
//   AppClosing({required super.savePath});
// }

class AppFirstLaunch extends AppState {
  // AppFirstLaunch({required super.savePath});
}

class AppReady extends AppState {
  final bool requiresRestart;
  AppReady({this.requiresRestart = false});
}

class AppCubit extends Cubit<AppState> {
  final AppRepository _appRepository;
  // final NotebookRepository _notebookRepository;

  AppCubit({
    // required NotebookRepository notebookRepository,
    required AppRepository appRepository,
  })  : _appRepository = appRepository,
        // _notebookRepository = notebookRepository,
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
        // await _notebookRepository.initialize(saveLocation!);

        print("Save location is set to : $saveLocation");
        print("The app is ready (supposedly)");
        emit(AppReady());
    }
  }

  // Future<void> reInitializeApp() async {
  //   emit(AppLoading(savePath: ''));
  //   await _initialize();
  // }

  void resetSettings() {
    _appRepository.clearAppSettings();
    // TODO:
    // Also reset other things but they haven't been implemented yet
  }

  void setDefaultFirstLaunch() async {
    // final Directory documentsDirectory =
    //     await getApplicationDocumentsDirectory();
    // final String saveLocation = p.join(documentsDirectory.path, appName);
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
    // await _notebookRepository.initialize(appSaveLocation);
    _appRepository.removeFirstLaunch();
    // _appRepository.setSaveLocation(saveLocation);
    emit(AppReady());
  }

  Future<void> closeApp() async {
    // emit(AppClosing(savePath: '')); 
    await windowManager.close();
  }

  Future<void> restartApp() async {
    final result = await Restart.restartApp();
    if (!result.success) {
      print("Couldn't restart the app");
    }
  }

  void setRequiresRestart() {
    emit(AppReady(requiresRestart: true));
  }
}
