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
  final bool inEditMode;
  IndexState({required this.content, required this.inEditMode, required this.noOfColumns, required this.headers});
}

class IndexCubit extends Cubit<IndexState> {
  IndexCubit() : super(IndexState(content: [], inEditMode: false, noOfColumns: 0, headers: [])) {
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
              ""
            ],
          ),
        ], headers: ['Title', 'Description', 'e1', 'e2', 'e3'],
      ),
    );
  }

  // Future<void> initialize() async {
  //   debugPrint("Initializing index...");
  //   emit(
  //     IndexState(
  //       inEditMode: false,
  //       noOfColumns: 2,
  //       content: [
  //         (id: 101, data: ["Unit 1", "This is the unit 1 description"]),
  //         (id: 102, data: ["Unit 2", "This is the unit 2 description"]),
  //         (
  //           id: 103,
  //           data: [
  //             "Intelligent Agents Introduction",
  //             "1. Characteristics of Intelligent Agents:- Agent Autonomy, Actuators ,Sensors, Environment, Performance Measure , Agent function and Agent Program. (Vacuum Cleaner Example, etc.)\n2. Agents and Environment:- Rational Agent , Discuss various environments, Specification of Task Environment (Using Examples).\n3. Typical Intelligent Agents and their Types:- Simple Reflex, Model based, Goal based and Utility based.(Discuss with Diagram).\nACTIVITY- 1 [6 marks] (Should be conducted by 20.12.2025 covering Module nos. 1 & 2)",
  //           ],
  //         ),
  //         (
  //           id: 104,
  //           data: [
  //             "Solving Problems by Searching",
  //             "1. Defining a problem for state space searching. (State Space Representation of Water-Jug Problem, N-Queen Problem, Monks and Demons problem, 8-Puzzle problem, etc.) (One or Two problem to be explained in class others can be given for practice). 1 7-19 \n2. Search Strategies:- Search Tree, Solution Path, Nodes, Open List, Closed List, concept of space and time complexity. 1 \n3. Uninformed Strategies:- BFS, Uniform Cost Search, DFS, Iterative Deepening, Depth Limited and Bidirectional. Discuss the Space and Time complexity of each Strategy. 8 \n4. Informed (Heuristics Strategies):- Concept of Heuristics, Admissibility and consistency, Greedy Best First Search, A* Algorithm. Discuss Admissibility, Consistency and Optimality of A*. \nACTIVITY-2 [6 marks] (Should be conducted by 20.01.2025 covering part of Module no. 3)",
  //           ],
  //         ),
  //         (
  //           id: 105,
  //           data: [
  //             "Knowledge Representation.",
  //             "1. Basic of Proposition Logic, Truth Tables, Atomic Sentences, Complex Sentences, Quantifiers , Connectives. \n2. First Order Predicate Logic. \n3. Unification. \n4. Forward Chaining and Backward Chaining. \n5. Resolution. \n6. Knowledge Representation using First order Predicate logic. \n7. Logical Agents (Knowledge-based agents, the Wumpus World, entailment, inference, sound and complete inference algorithms, propositional logic, various inference procedures such as model checking and theorem proving, forward and backward chaining etc.) \nACTIVITY-4 [6 marks] (Must be conducted by 15.03.2024 covering Module no. 5 prior to Mid Semester Exam) NOTE: 50% of Activities marks i.e. 15 marks to be announced to students before AI mid semester example",
  //           ],
  //         ),
  //         (id: 106, data: ["Unit 1", "This is the unit 1 description"]),
  //         (id: 107, data: ["Unit 2", "This is the unit 2 description"]),
  //         (
  //           id: 108,
  //           data: [
  //             "Intelligent Agents Introduction",
  //             "1. Characteristics of Intelligent Agents:- Agent Autonomy, Actuators ,Sensors, Environment, Performance Measure , Agent function and Agent Program. (Vacuum Cleaner Example, etc.)\n2. Agents and Environment:- Rational Agent , Discuss various environments, Specification of Task Environment (Using Examples).\n3. Typical Intelligent Agents and their Types:- Simple Reflex, Model based, Goal based and Utility based.(Discuss with Diagram).\nACTIVITY- 1 [6 marks] (Should be conducted by 20.12.2025 covering Module nos. 1 & 2)",
  //           ],
  //         ),
  //         (id: 109, data: ["Unit 1", "This is the unit 1 description"]),
  //         (id: 110, data: ["Unit 2", "This is the unit 2 description"]),
  //         (
  //           id: 111,
  //           data: [
  //             "Intelligent Agents Introduction",
  //             "1. Characteristics of Intelligent Agents:- Agent Autonomy, Actuators ,Sensors, Environment, Performance Measure , Agent function and Agent Program. (Vacuum Cleaner Example, etc.)\n2. Agents and Environment:- Rational Agent , Discuss various environments, Specification of Task Environment (Using Examples).\n3. Typical Intelligent Agents and their Types:- Simple Reflex, Model based, Goal based and Utility based.(Discuss with Diagram).\nACTIVITY- 1 [6 marks] (Should be conducted by 20.12.2025 covering Module nos. 1 & 2)",
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void addUnit(String unitTitle) {
    // final String jsonDesc = jsonEncode(unitDescription);
    final ({int id, List<String> data}) unit = (
      id: DateTime.now().millisecondsSinceEpoch,
      data: [unitTitle],
    );
    final newState = [...state.content, unit];
    emit(IndexState(content: newState, inEditMode: false, noOfColumns: state.noOfColumns, headers: state.headers));
  }

  void editUnitDesc(int id, String description) {
    final index = state.content.indexWhere((tuple) => tuple.id == id);
    final newState = [...state.content];
    newState[index].data[1] = description;
    emit(IndexState(content: newState, inEditMode: state.inEditMode, noOfColumns: state.noOfColumns, headers: state.headers));
  }

  void editUnitData(int id, int position, String data) {
    final index = state.content.indexWhere((tuple) => tuple.id == id);
    final newState = [...state.content];
    newState[index].data[position] = data;
    emit(IndexState(content: newState, inEditMode: state.inEditMode, noOfColumns: state.noOfColumns, headers: state.headers));
  }

  void toggleEditMode() {
    emit(IndexState(content: state.content, inEditMode: !state.inEditMode, noOfColumns: state.noOfColumns, headers: state.headers));
  }
}
