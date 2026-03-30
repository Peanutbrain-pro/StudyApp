import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Notebooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}

@DriftDatabase(tables: [Notebooks])
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
