import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studyapp/constants.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:path/path.dart' as p;
import 'package:studyapp/data/repositories/notebook_repository.dart';

sealed class AppState {
  final String savePath;
  AppState({required this.savePath});
}

class AppLoading extends AppState {
  AppLoading({required super.savePath});
}

class AppFirstLaunch extends AppState {
  AppFirstLaunch({required super.savePath});
}

class AppReady extends AppState {
  AppReady({required super.savePath});
}

class AppCubit extends Cubit<AppState> {
  final AppRepository _appRepository;
  // final NotebookRepository _notebookRepository;

  AppCubit({
    // required NotebookRepository notebookRepository,
    required AppRepository appRepository,
  })  : _appRepository = appRepository,
        // _notebookRepository = notebookRepository,
        super(AppLoading(savePath: '')) {
    _initialize();
  }

  Future<void> _initialize() async {
    final status = await _appRepository.getAppStatus();
    switch (status) {
      case AppInitStatus.firstLaunch:
        print("This app is launching for the first time");
        emit(AppFirstLaunch(savePath: ''));

      case AppInitStatus.ready:
        final saveLocation = await _appRepository.getSaveLocation();
        // await _notebookRepository.initialize(saveLocation!);

        print("Save location is set to : $saveLocation");
        print("The app is ready (supposedly)");
        emit(AppReady(savePath: saveLocation!));
    }
  }

  void clearSettings() {
    _appRepository.clearAppSettings();
    emit(AppFirstLaunch(savePath: ''));
  }

  void setDefaultFirstLaunch() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String saveLocation = p.join(documentsDirectory.path, appName);
    _appRepository.removeFirstLaunch();
    _appRepository.setSaveLocation(saveLocation);
    print("The save location is saved to the default");
    _onFirstConfigFinished(saveLocation);
  }

  void _onFirstConfigFinished(String appSaveLocation) async {
    // await _notebookRepository.initialize(appSaveLocation);
    emit(AppReady(savePath: appSaveLocation));
  }
}
