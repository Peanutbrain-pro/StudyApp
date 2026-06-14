import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/database_tables.dart';

part 'app_database.g.dart';

// class Notebooks extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get name => text().withLength(min: 1, max: 64)();
//   DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
// }

// class IndexTable extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   IntColumn get notebookId => integer().references(Notebooks, #id)();
//   TextColumn get title => text().withLength(max: 500).nullable()();
//   TextColumn get desc => text().withLength(max: 5000).nullable()();
//   IntColumn get position => integer()();
//   TextColumn get extraInfo => text().nullable()();
//   DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
//   DateTimeColumn get modifiedAt => dateTime().clientDefault(() => DateTime.now())();
// }

// class UiPreferences extends Table {
//   IntColumn get notebookId => integer().references(Notebooks, #id)();
//   TextColumn get preferences => text().nullable()();
// }

@DriftDatabase(tables: [Notebooks, IndexItems, UiPreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String saveLocation) : super(_openConnection(saveLocation));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(String saveLocation) {
    return driftDatabase(
      name: 'appdb',
      native: DriftNativeOptions(
        databaseDirectory: () async {
          final databaseSaveLocation = p.join(saveLocation, "data");
          return databaseSaveLocation;
        },
      ),
    );
  }
}
