// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  IndexCubit()
    : super(IndexState(content: [], inEditMode: false, noOfColumns: 0, headers: [], columnWidths: [])) {
    // initialize();
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
        columnWidths: List<double>.generate(5, (index) {
          if (index == 1) return 500;
          return 100;
        }),
      ),
    );
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
