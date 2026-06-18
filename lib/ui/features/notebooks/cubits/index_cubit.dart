// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/ui_preferences_repository.dart';

class IndexState {
  // final List<List<String?>> content;
  // something like this for a single unit
  // {id: 1, data: ["Unit Title", "JSON  unit description", "extra column", "extra column" ...]
  // ... }
  final List<({int id, List<String> data})> content;
  final int noOfColumns;
  final List<String> headers;
  final List<double> columnWidths;
  final bool inEditMode;
  IndexState({
    required this.content,
    required this.inEditMode,
    required this.noOfColumns,
    required this.headers,
    required this.columnWidths,
  });
}

class IndexCubit extends Cubit<IndexState> {
  final UiPreferencesRepository _uiPreferencesRepository;
  final int notebookId;

  IndexCubit({required UiPreferencesRepository uiPreferencesRepository, required this.notebookId})
    : _uiPreferencesRepository = uiPreferencesRepository,
      super(IndexState(content: [], inEditMode: false, noOfColumns: 0, headers: ["Unit", "Description"], columnWidths: [])) {
    initialize();
  }

  Future<void> initialize() async {
    if (isClosed) return;

    emit(
      IndexState(
        inEditMode: false,
        noOfColumns: 5,
        content: [
          (
            id: 101,
            data: [
              "[{\"insert\":\"Unit 1\\n\"}]",
              "[{\"insert\":\"Quick Start\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Hello World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
            ],
          ),
          (
            id: 102,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 103,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 104,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 105,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 106,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 107,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 108,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 109,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
          (
            id: 110,
            data: [
              "[{\"insert\":\"Unit 2\\n\"}]",
              "[{\"insert\":\"Quick Start 2\"},{\"insert\":\"\\n\",\"attributes\":{\"heading\":1}},{\"insert\":\"Goodbye World\\n\"}]",
              "[{\"insert\":\"Extra Column\\n\"}]",
              "[{\"insert\":\"Extra Column 2\\n\"}]",
              "[{\"insert\":\"Extra Column 3\\n\"}]",
              "",
            ],
          ),
        ],
        headers: ['Title', 'Description', 'e1', 'e2', 'e3'],
        columnWidths: await getColumnWidths(notebookId, 5),
      ),
    );
  }

  void saveColumnWidths(int notebookId, List<double> columnWidths) {
    print("saving to database the column widths $columnWidths");
    _uiPreferencesRepository.saveColumnWidths(notebookId, columnWidths);
  }

  Future<List<double>> getColumnWidths(int notebookId, int noOfColumns) async {
    print("Trying to get Column widths from database");
    final columnWidths = await _uiPreferencesRepository.getColumnWidths(notebookId, "Index");
    if (columnWidths == null) {
      print("Creating new columnWidths");
      final newWidths = List<double>.generate(noOfColumns, (index) {
        if (index == 1) return 500;
        return 100;
      });
      print("Saving to database");
      saveColumnWidths(notebookId, newWidths);
      return newWidths;
    }
  
    print("Found column Widths, giving it now: $columnWidths");
    return columnWidths;
  }

  void addUnit(String unitTitle) {
    // final String jsonDesc = jsonEncode(unitDescription);
    final ({int id, List<String> data}) unit = (id: DateTime.now().millisecondsSinceEpoch, data: [unitTitle]);
    final newState = [...state.content, unit];
    emit(
      IndexState(
        content: newState,
        inEditMode: false,
        noOfColumns: state.noOfColumns,
        headers: state.headers,
        columnWidths: state.columnWidths,
      ),
    );
  }

  void editUnitDesc(int id, String description) {
    final index = state.content.indexWhere((tuple) => tuple.id == id);
    final newState = [...state.content];
    newState[index].data[1] = description;
    emit(
      IndexState(
        content: newState,
        inEditMode: state.inEditMode,
        noOfColumns: state.noOfColumns,
        headers: state.headers,
        columnWidths: state.columnWidths,
      ),
    );
  }

  void editUnitData(int id, int position, String data) {
    final index = state.content.indexWhere((tuple) => tuple.id == id);
    final newState = [...state.content];
    newState[index].data[position] = data;
    emit(
      IndexState(
        content: newState,
        inEditMode: state.inEditMode,
        noOfColumns: state.noOfColumns,
        headers: state.headers,
        columnWidths: state.columnWidths,
      ),
    );
  }

  void toggleEditMode() {
    emit(
      IndexState(
        content: state.content,
        inEditMode: !state.inEditMode,
        noOfColumns: state.noOfColumns,
        headers: state.headers,
        columnWidths: state.columnWidths,
      ),
    );
  }
}
