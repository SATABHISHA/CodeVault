import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../windows_desktop/data/local_database.dart';
import 'part_repository.dart';

/// A [PartRepository] implementation that reads and writes to the local
/// SQLite/Drift database. Used on Windows (offline-first) only.
class LocalPartRepository implements PartRepository {
  LocalPartRepository(this._db);
  final LocalDatabase _db;

  // ── helpers ──────────────────────────────────────────────────────────────

  PartRecord _fromRow(Part row) => PartRecord(
    id: row.id,
    number: row.description ?? row.id, // description stores the part number
    name: row.item,
    model: row.model ?? '',
    drCode: row.defaultDrCode ?? '',
    packQuantity: row.defaultPackQuantity,
    barcodeType: row.barcodeType,
    version: 1,
  );

  // ── interface ─────────────────────────────────────────────────────────────

  @override
  Future<List<PartRecord>> list(String tenantId, {String search = ''}) async {
    final query = _db.select(_db.parts)
      ..where((t) => t.companyId.equals(tenantId) & t.active.equals(true));

    if (search.isNotEmpty) {
      query.where((t) => t.item.like('%$search%') | t.model.like('%$search%'));
    }

    final rows = await query.get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<PartRecord> create(String tenantId, Map<String, dynamic> data) async {
    const uuid = Uuid();
    final id = uuid.v4();
    await _db
        .into(_db.parts)
        .insert(
          PartsCompanion.insert(
            id: id,
            companyId: tenantId,
            item: data['item_name'] as String? ?? '',
            model: Value(data['item_model'] as String?),
            description: Value(data['part_number'] as String?),
            defaultDrCode: Value(data['default_dr_code'] as String?),
            defaultPackQuantity: Value(
              data['default_pack_quantity'] as int? ?? 1,
            ),
            barcodeType: Value(data['barcode_type'] as String? ?? 'code128'),
            active: const Value(true),
          ),
        );
    final row = await (_db.select(
      _db.parts,
    )..where((t) => t.id.equals(id))).getSingle();
    return _fromRow(row);
  }

  @override
  Future<PartRecord> update(
    String tenantId,
    PartRecord part,
    Map<String, dynamic> data,
  ) async {
    final changed =
        await (_db.update(_db.parts)..where(
              (t) => t.companyId.equals(tenantId) & t.id.equals(part.id),
            ))
            .write(
              PartsCompanion(
                item: Value(data['item_name'] as String? ?? part.name),
                model: Value(data['item_model'] as String?),
                description: Value(data['part_number'] as String?),
                defaultDrCode: Value(data['default_dr_code'] as String?),
                defaultPackQuantity: Value(
                  data['default_pack_quantity'] as int? ?? part.packQuantity,
                ),
                barcodeType: Value(
                  data['barcode_type'] as String? ?? part.barcodeType,
                ),
                updatedAt: Value(DateTime.now()),
              ),
            );
    if (changed != 1) {
      throw StateError('The selected part no longer exists in this company.');
    }
    final row =
        await (_db.select(_db.parts)..where(
              (t) => t.companyId.equals(tenantId) & t.id.equals(part.id),
            ))
            .getSingle();
    return _fromRow(row);
  }

  @override
  Future<void> delete(String tenantId, String id) async {
    await (_db.delete(_db.parts)..where((t) => t.id.equals(id))).go();
  }
}
