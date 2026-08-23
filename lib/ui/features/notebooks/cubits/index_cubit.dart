// import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path/path.dart';
import 'package:studyapp/data/database/app_database.dart';
import 'package:studyapp/data/repositories/index_repository.dart';
import 'package:studyapp/data/repositories/ui_preferences_repository.dart';

sealed class IndexState {}

class IndexLoading extends IndexState {}

class IndexReady extends IndexState {
  final List<({int id, List<String?> data})> content;
  final int noOfColumns;
  final List<String?> headers;
  final List<double> columnWidths;
  final bool inEditMode;
  IndexReady({
    required this.content,
    required this.inEditMode,
    required this.noOfColumns,
    required this.headers,
    required this.columnWidths,
  });
}

class IndexCubit extends Cubit<IndexState> {
  final UiPreferencesRepository _uiPreferencesRepository;
  final IndexRepository _indexRepository;
  final int notebookId;

  IndexCubit({
    required UiPreferencesRepository uiPreferencesRepository,
    required this.notebookId,
    required IndexRepository indexRepository,
  }) : _indexRepository = indexRepository,
       _uiPreferencesRepository = uiPreferencesRepository,
       super(IndexLoading()) {
    initialize();
  }

  Future<void> initialize() async {
    if (isClosed) return;

    final units = await getUnits(notebookId);
    emit(
      IndexReady(
        content: units.content,
        columnWidths: units.columnWidths,
        headers: units.headers.headers,
        inEditMode: false,
        noOfColumns: units.headers.noOfColumns,
      ),
    );
  }

  void saveColumnWidths(int notebookId, List<double> columnWidths) {
    print("saving to database the column widths $columnWidths");
    _uiPreferencesRepository.saveColumnWidths(notebookId, "Index", columnWidths);
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

  Future<List<({int id, List<String?> data})>> _convertIndexItemsToContent(List<IndexItem> indexItems) async {
    List<({int id, List<String?> data})> content = [];
    for (IndexItem item in indexItems) {
      List<String?> data = [];
      data.add(item.title);
      data.add(item.description);
      data.addAll(List<String?>.from(jsonDecode((item.extraInfo ?? "[]"))));
      content.add((id: item.id, data: data));
    }
    return content;
  }

  Future<
    ({
      List<IndexItem> items,
      List<({List<String?> data, int id})> content,
      ({List<String?> headers, int noOfColumns}) headers,
      List<double> columnWidths,
    })
  >
  getUnits(int notebookId) async {
    final items = await _indexRepository.getUnits(notebookId);
    final content = await _convertIndexItemsToContent(items);
    final headers = await _indexRepository.getHeaders(notebookId);
    final columnWidths = await getColumnWidths(notebookId, headers.noOfColumns);

    return (items: items, content: content, headers: headers, columnWidths: columnWidths);
    // emit(
    //   IndexReady(
    //     content: content,
    //     inEditMode: false,
    //     noOfColumns: headers.noOfColumns,
    //     headers: headers.headers,
    //     columnWidths: columnWidths,
    //   ),
    // );
  }

  Future<void> addUnit({int position = -1}) async {
    if (state is IndexReady) {
      final currentState = state as IndexReady;

      final row = await _indexRepository.addUnit(notebookId, position: position);
      final newUnit = (
        id: row.id,
        data: [row.title, row.description, ...List<String?>.from(jsonDecode(row.extraInfo ?? "[]"))],
      );

      // final String jsonDesc = jsonEncode(unitDescription);
      // final ({int id, List<String> data}) unit = (
      //   id: DateTime.now().millisecondsSinceEpoch,
      //   data: [unitTitle],
      // );
      final newStateContent = [...currentState.content]..insert(row.position, newUnit);
      emit(
        IndexReady(
          content: newStateContent,
          inEditMode: true,
          noOfColumns: currentState.noOfColumns,
          headers: currentState.headers,
          columnWidths: currentState.columnWidths,
        ),
      );
    }
  }

  void deleteUnit({required int position}) {}
  void deleteAllItems() {
    _indexRepository.deleteAllItems(notebookId);
    if (state is IndexReady) {
      final currentState = state as IndexReady;
      emit(
        IndexReady(
          columnWidths: currentState.columnWidths,
          content: [],
          inEditMode: currentState.inEditMode,
          noOfColumns: currentState.noOfColumns,
          headers: currentState.headers,
        ),
      );
    }
  }

  void addHeader(int notebookId) {
    if (state is IndexReady) {
      _indexRepository.addHeader(notebookId);
      _uiPreferencesRepository.addColumn(notebookId);
      final currentState = state as IndexReady;
      var headers = [...currentState.headers, null];
      var columnWidths = [...currentState.columnWidths, 100.0];
      emit(
        IndexReady(
          content: currentState.content,
          columnWidths: columnWidths,
          headers: headers,
          inEditMode: currentState.inEditMode,
          noOfColumns: currentState.noOfColumns + 1,
        ),
      );
    }
  }

  void editHeader(int notebookId, String? title, int columnIndex) {
    if (state is IndexReady) {
      // update database
      _indexRepository.editHeader(notebookId, columnIndex, title);

      final currentState = state as IndexReady;

      emit(
        IndexReady(
          content: currentState.content,
          columnWidths: currentState.columnWidths,
          headers: currentState.headers..replaceRange(columnIndex, columnIndex + 1, [title]),
          inEditMode: currentState.inEditMode,
          noOfColumns: currentState.noOfColumns,
        ),
      );
    }
  }

  void editUnitDesc(int id, String description) {
    if (state is IndexReady) {
      final currentState = state as IndexReady;

      final index = currentState.content.indexWhere((tuple) => tuple.id == id);
      final newState = [...currentState.content];
      newState[index].data[1] = description;
      emit(
        IndexReady(
          content: newState,
          inEditMode: currentState.inEditMode,
          noOfColumns: currentState.noOfColumns,
          headers: currentState.headers,
          columnWidths: currentState.columnWidths,
        ),
      );
    }
  }

  Future<void> editUnitData(int id, int columnIndex, String data) async {
    if (state is IndexReady) {
      // update database
      _indexRepository.updateUnit(id, data, columnIndex);

      final currentState = state as IndexReady;
      final index = currentState.content.indexWhere((tuple) => tuple.id == id);
      final newState = [...currentState.content];
      newState[index].data[columnIndex] = data;
      emit(
        IndexReady(
          content: newState,
          inEditMode: currentState.inEditMode,
          noOfColumns: currentState.noOfColumns,
          headers: currentState.headers,
          columnWidths: currentState.columnWidths,
        ),
      );
    }
  }

  void toggleEditMode() {
    if (state is IndexReady) {
      final currentState = state as IndexReady;
      emit(
        IndexReady(
          content: currentState.content,
          inEditMode: !currentState.inEditMode,
          noOfColumns: currentState.noOfColumns,
          headers: currentState.headers,
          columnWidths: currentState.columnWidths,
        ),
      );
    }
  }

  IndexReady get readyState => state as IndexReady;
}
