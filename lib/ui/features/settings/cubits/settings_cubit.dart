import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/ui/shared/utilities/dialog_helper.dart';
import 'package:window_manager/window_manager.dart';

class SettingsState {
  final String saveLocation;
  const SettingsState({required this.saveLocation}); 
}

class SettingsCubit extends Cubit<SettingsState>{
  final AppRepository appRepository;
  final NotebookRepository notebookRepository;
 
  SettingsCubit({required this.appRepository, required this.notebookRepository}) : super(
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

  void resetSettings(BuildContext context) async {
    // Not really implemented right now as there are no other setting than save location, but will add soon
    final bool confirmed = await DialogHelper.getConfirmation(context, "Reset All Settings", "Are you sure you want to reset all settings?", "Reset");
    if (!confirmed) return;
    
    appRepository.clearAppSettings();
  }

  void deleteAppData(BuildContext context) async {
    final bool confirmed = await DialogHelper.getConfirmation(context, "Delete All App Data", "Are you sure you want to delete all Notebooks' data (Sources, PYQs, Notes)? Please backup the data before deleting. The app needs to be restarted, so it will close.", "Delete");
    if (!confirmed) return;
    
    await notebookRepository.resetDatabase();
    
    // SystemNavigator.pop();
    windowManager.destroy();

  }

  Future<void> completeReset(BuildContext context) async {
    final bool confirmed = await DialogHelper.getConfirmation(context, "Reset App to Factory Settings", "Are you sure you want to delete and reset everything? You will get the first launch screen on next startup. The app will close now", "Yes");
    if (!confirmed) return;

    final notebooksDirectoryDeleted = await notebookRepository.deleteNotebooksDirectory();
    if (!notebooksDirectoryDeleted) {
      await DialogHelper.showError(context, "Unable to Delete Notebooks", "Couldn't delete the notebook data. Please check that no other application is using that folder (including File Explorer)");
      return;
    }
    await notebookRepository.resetDatabase();
    print("All notebooks data from database deleted");
    appRepository.completeHardReset(); 
    print("All shared preferences data deleted");

    windowManager.destroy();
  }
}