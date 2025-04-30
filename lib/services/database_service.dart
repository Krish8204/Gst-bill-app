import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/product.dart';
import '../models/bill.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gst_billing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      var options = OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      );

      return await factory.openDatabase(filePath, options: options);
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        gstPercentage REAL NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billNumber TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        customerName TEXT,
        customerPhone TEXT,
        subtotal REAL NOT NULL,
        totalCgst REAL NOT NULL,
        totalSgst REAL NOT NULL,
        totalAmount REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bill_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        gstPercentage REAL NOT NULL,
        FOREIGN KEY (billId) REFERENCES bills (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  Future<Product> insertProduct(Product product) async {
    try {
      final db = await database;
      final id = await db.insert('products', product.toMap());
      return product.copyWith(id: id);
    } catch (e) {
      print('Error inserting product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('products');
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<int> insertBill(Bill bill) async {
    final db = await database;
    final billId = await db.insert('bills', bill.toMap());

    for (var item in bill.items) {
      await db.insert('bill_items', {
        ...item.toMap(),
        'billId': billId,
      });
    }

    return billId;
  }

  Future<List<Bill>> getBillsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> billMaps = await db.query(
      'bills',
      where: 'dateTime BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    List<Bill> bills = [];
    for (var billMap in billMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'bill_items',
        where: 'billId = ?',
        whereArgs: [billMap['id']],
      );

      List<BillItem> items = [];
      for (var itemMap in itemMaps) {
        final product = await getProductById(itemMap['productId'] as int);
        if (product != null) {
          items.add(BillItem(
            product: product,
            quantity: itemMap['quantity'] as int,
          ));
        }
      }

      bills.add(Bill.fromMap(billMap, items));
    }

    return bills;
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<void> deleteProduct(int id) async {
    try {
      final db = await database;
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
