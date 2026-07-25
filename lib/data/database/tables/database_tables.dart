import 'package:drift/drift.dart';
// import 'package:studyapp/data/database/converters/json_string_converter.dart';

class Notebooks extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn name = text().withLength(min: 1, max: 100)();
  late final IntColumn noOfColumns = integer()
      .check(noOfColumns.isBiggerOrEqualValue(2) & noOfColumns.isSmallerOrEqualValue(8))
      .clientDefault(() => 2)();
  late final TextColumn headers = text().nullable().clientDefault(() => "[\"Title\", \"Description\"]")();
  late final DateTimeColumn createdAt = dateTime().clientDefault(() => DateTime.now())();
}

class IndexItems extends Table {
  late final IntColumn id = integer().autoIncrement()();
  late final IntColumn notebookId = integer().references(Notebooks, #id, onDelete: .cascade)();
  late final TextColumn title = text().withLength(max: 500).nullable()();
  late final TextColumn description = text().withLength(max: 5000).nullable()();
  late final IntColumn position = integer()();
  late final TextColumn extraInfo = text().nullable()();
  late final DateTimeColumn createdAt = dateTime().clientDefault(() => DateTime.now()).nullable()();
  late final DateTimeColumn modifiedAt = dateTime().clientDefault(() => DateTime.now()).nullable()();
}

class UiPreferences extends Table {
  late final IntColumn notebookId = integer().references(Notebooks, #id, onDelete: .cascade)();
  late final TextColumn preferences = text().nullable()();
}

class Sources extends Table {
  late final IntColumn indexId = integer().references(IndexItems, #id, onDelete: .cascade)();
  late final IntColumn id = integer().autoIncrement()();
  late final TextColumn path = text()();
  late final TextColumn type = text()();
}

class Notes extends Table {
  late final IntColumn notebookId = integer().references(Notebooks, #id, onDelete: .cascade)();
  late final TextColumn data = text()();
}
