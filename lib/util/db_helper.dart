import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:product_app/models/Product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  static Database? _database;

  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            price INTEGER,
            stock INTEGER,
            thumbnail TEXT
          )
          ''',
        );
      },
    );
  }

  Future<void> addProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Actualizar las sumas de precios y stock en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final currentPriceSum = prefs.getInt('priceSum') ?? 0;
    final currentStockSum = prefs.getInt('stockSum') ?? 0;
    final newPriceSum = currentPriceSum + product.price!;
    final newStockSum = currentStockSum + product.stock!;
    await prefs.setInt('priceSum', newPriceSum);
    await prefs.setInt('stockSum', newStockSum);
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;

    // Obtener el producto que se va a eliminar
    final productToDelete = await getProductById(id);

    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Actualizar las sumas de precios y stock en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final currentPriceSum = prefs.getInt('priceSum') ?? 0;
    final currentStockSum = prefs.getInt('stockSum') ?? 0;
    final newPriceSum = currentPriceSum - productToDelete.price!; //* 0; para volver a setear a 0 porque antes agregue datoss
    final newStockSum = currentStockSum - productToDelete.stock!;
    await prefs.setInt('priceSum', newPriceSum);
    await prefs.setInt('stockSum', newStockSum);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (index) {
      return Product.fromJson(maps[index]);
    });
  }

  Future<Product> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      throw Exception('Product not found');
    }
  }
}