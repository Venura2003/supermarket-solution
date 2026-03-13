import 'package:supermarket_flutter_app/core/models/product_models.dart';
import 'package:supermarket_flutter_app/core/data/local_db.dart';
import 'package:sqflite/sqflite.dart';

class ProductDao {
  final LocalDb _db = LocalDb();

  Future<void> upsertProduct(Product p) async {
    final db = await _db.database;
    final map = p.toMap();
    map['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    await db.insert('products', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Product?> getProductById(String id) async {
    final db = await _db.database;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _db.database;
    final rows = await db.query('products');
    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<void> deleteProduct(String id) async {
    final db = await _db.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearProducts() async {
    final db = await _db.database;
    await db.delete('products');
  }
}
