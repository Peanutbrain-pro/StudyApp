import 'package:drift/drift.dart';
import 'package:studyapp/data/database/converters/json_string_converter.dart';

class Notebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
}

class IndexItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get notebookId => integer().references(Notebooks, #id)();
  TextColumn get unitTitle => text().withLength(min: 1, max: 128)();
  TextColumn get unitDescription => text().withLength(max: 1600).nullable()();
  IntColumn get position => integer()();
  TextColumn get extraColumns => text().map(const JsonStringConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get modifiedAt => dateTime().clientDefault(() => DateTime.now())();
}

class Sources extends Table {
  IntColumn get indexId => integer().references(IndexItems, #id)();
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text()();
  TextColumn get type => text()();
}
