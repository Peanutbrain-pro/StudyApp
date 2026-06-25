import 'package:drift/drift.dart';
// import 'package:studyapp/data/database/converters/json_string_converter.dart';

class Notebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
}

class IndexItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get notebookId => integer().references(Notebooks, #id)();
  TextColumn get title => text().withLength(max: 500).nullable()();
  TextColumn get description => text().withLength(max: 5000).nullable()();
  IntColumn get position => integer()();
  TextColumn get extraInfo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now()).nullable()();
  DateTimeColumn get modifiedAt => dateTime().clientDefault(() => DateTime.now()).nullable()();
}

class UiPreferences extends Table {
  IntColumn get notebookId => integer().references(Notebooks, #id)();
  TextColumn get preferences => text().nullable()();
}

class Sources extends Table {
  IntColumn get indexId => integer().references(IndexItems, #id)();
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get type => text()();
}
