import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/repositories/app_repository.dart';
import 'package:studyapp/data/repositories/notebook_repository.dart';
import 'package:studyapp/services/font_service.dart';
import 'package:studyapp/ui/app/cubits/app_cubit.dart';
import 'package:studyapp/ui/shared/utilities/dialog_helper.dart';

class SettingsState {
  final String saveLocation;
  final String appFont;
  final String editorFont;
  final List<String> availableFonts;
  final bool isLoadingFonts;

  const SettingsState({
    required this.saveLocation,
    this.appFont = 'System Default',
    this.editorFont = 'System Default',
    this.availableFonts = const ['System Default'],
    this.isLoadingFonts = false,
  });

  SettingsState copyWith({
    String? saveLocation,
    String? appFont,
    String? editorFont,
    List<String>? availableFonts,
    bool? isLoadingFonts,
  }) {
    return SettingsState(
      saveLocation: saveLocation ?? this.saveLocation,
      appFont: appFont ?? this.appFont,
      editorFont: editorFont ?? this.editorFont,
      availableFonts: availableFonts ?? this.availableFonts,
      isLoadingFonts: isLoadingFonts ?? this.isLoadingFonts,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final AppRepository appRepository;
  final NotebookRepository notebookRepository;

  SettingsCubit({required this.appRepository, required this.notebookRepository})
      : super(SettingsState(
          saveLocation: appRepository.getSaveLocation() ?? "",
          appFont: appRepository.getAppFont(),
          editorFont: appRepository.getEditorFont(),
          availableFonts: FontService.cachedFonts,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final saveLocation = appRepository.getSaveLocation() ?? '';
    final appFont = appRepository.getAppFont();
    final editorFont = appRepository.getEditorFont();
    emit(state.copyWith(
      saveLocation: saveLocation,
      appFont: appFont,
      editorFont: editorFont,
      availableFonts: FontService.cachedFonts,
    ));

    final fonts = await FontService.getSystemFonts();
    if (fonts != state.availableFonts) {
      emit(state.copyWith(availableFonts: fonts));
    }
  }

  Future<void> setAppFont(BuildContext context, String font) async {
    await appRepository.setAppFont(font);
    if (context.mounted) {
      await context.read<AppCubit>().setAppFont(font);
    }
    emit(state.copyWith(appFont: font));
  }

  Future<void> setEditorFont(BuildContext context, String font) async {
    await appRepository.setEditorFont(font);
    if (context.mounted) {
      await context.read<AppCubit>().setEditorFont(font);
    }
    emit(state.copyWith(editorFont: font));
  }

  Future<void> changeSaveLocation(BuildContext context) async {
    final bool confirmed = await DialogHelper.getConfirmation(
        context,
        false,
        "Change Notebook Data Location",
        "Do you want to change the location of your notebooks' data? If the new folder doesn't already have the data files then new ones will be created. The app needs a restart so it will close.",
        "Yes");
    if (!confirmed || !context.mounted) {
      return;
    } 

    String? selectedDirectory = await FilePicker.getDirectoryPath();
    if (selectedDirectory == null) {
      return;
    }

    appRepository.setSaveLocation(selectedDirectory);
    emit(state.copyWith(saveLocation: selectedDirectory));
    
    if (context.mounted) {
      context.read<AppCubit>().setRequiresRestart();
    }
  }

  void resetSettings(BuildContext context) async {
    final bool confirmed = await DialogHelper.getConfirmation(
        context, true, "Reset All Settings", "Are you sure you want to reset all settings?", "Reset");
    if (!confirmed) return;

    appRepository.clearAppSettings();
  }

  void deleteAppData(BuildContext context) async {
    final bool confirmed = await DialogHelper.getConfirmation(
        context,
        true,
        "Delete All App Data",
        "Are you sure you want to delete all Notebooks' data (Sources, PYQs, Notes)? Please backup the data before deleting. The app needs to be restarted, so it will close.",
        "Delete");
    if (!confirmed || !context.mounted) return;

    await notebookRepository.resetDatabase();

    if (context.mounted) {
      context.read<AppCubit>().setRequiresRestart();
    }
  }

  Future<void> completeReset(BuildContext context) async {
    final bool confirmed = await DialogHelper.getConfirmation(
        context,
        true,
        "Reset App to Factory Settings",
        "Are you sure you want to delete and reset everything? You would need to restart the app",
        "Yes");
    if (!confirmed || !context.mounted) return;

    final notebooksDirectoryDeleted = await notebookRepository.deleteNotebooksDirectory();
    if (!notebooksDirectoryDeleted) {
      if (context.mounted) {
        await DialogHelper.showError(context, "Unable to Delete Notebooks",
            "Couldn't delete the notebook data. Please check that no other application is using that folder");
      }
      return;
    }
    await notebookRepository.resetDatabase();
    appRepository.completeHardReset();

    if (context.mounted) {
      context.read<AppCubit>().setRequiresRestart();
    }
  }
}
