import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'sync_service.g.dart';

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get data => text()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Items])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File(p.join(docs.path, 'infoplus.sqlite'));
    return NativeDatabase(file);
  });
}

extension SyncService on LocalDatabase {
  Future<List<Item>> getPending() {
    return (select(items)..where((tbl) => tbl.synced.equals(false))).get();
  }

  Future<int> markSynced(String id) {
    return (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(synced: Value(true)),
    );
  }

  Future<void> pushPendingToServer() async {
    final pending = await getPending();
    for (final item in pending) {
      await markSynced(item.id);
    }
  }
}