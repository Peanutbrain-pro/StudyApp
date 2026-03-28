import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/app_repository.dart';

class SettingsState {
  final String saveLocation;
  const SettingsState({required this.saveLocation}); 
}

class SettingsCubit extends Cubit<SettingsState>{
  final AppRepository appRepository;
 
  SettingsCubit({required this.appRepository}) : super(
    SettingsState(saveLocation: "")) {
      _loadSettings();
    }

  Future<void> _loadSettings() async {
    final saveLocation = await appRepository.getSaveLocation();
    emit(SettingsState(saveLocation: saveLocation!));
  }

  Future<void> changeSaveLocation() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      print("Directory selection canceled by user");
      return;
    }

    appRepository.setSaveLocation(selectedDirectory);
    emit(SettingsState(saveLocation: selectedDirectory));
  }
}