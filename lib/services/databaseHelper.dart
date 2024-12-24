import 'package:kas_manager/constFiles/strings.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database?> initializeDatabase() async =>
      await openDatabase(join(await getDatabasesPath(), databaseName),
          version: 2,
          onCreate: (Database db, int version) => onCreate(db, version));

  onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $transactionTable('
      'id INTEGER PRIMARY KEY,'
      'title TEXT,'
      'description TEXT,'
      'amount TEXT,'
      'isIncome INTEGER,'
      'category TEXT,'
      'dateTime TEXT'
      ');',
    );

    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL
    );
    ''');
  }

  Future<int> registerUser(
      String username, String password, String role) async {
    final db = await initializeDatabase();
    return await db!.insert('users', {
      'username': username,
      'password': password,
      'role': role,
    });
  }

  Future<Map<String, dynamic>?> loginUser(
      String username, String password) async {
    final db = await initializeDatabase();
    final List<Map<String, dynamic>> users = await db!.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  Future<void> insertData(String tableName, Map<String, Object?> data) async {
    final db = await initializeDatabase();
    print('data to insert');
    print(data);
    await db!.insert(tableName, data);
  }

  Future<void> updateData(
      String tableName, Map<String, Object?> data, int id) async {
    final db = await initializeDatabase();
    await db!.update(tableName, data, where: 'id = ?', whereArgs: [id]);
    print('success update data');
  }

  Future<void> deleteData(String tableName, int id) async {
    final db = await initializeDatabase();
    await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getData(String tableName) async {
    final db = await initializeDatabase();
    return await db!.query(tableName, orderBy: "dateTime DESC");
  }

  Future<List<Map<String, dynamic>>> getDateRangeData(
      String tableName, String fromDate, String toDate) async {
    final db = await initializeDatabase();

    // Pastikan `fromDate` dan `toDate` memiliki format yang sesuai
    final String formattedFromDate = "$fromDate 00:00:00";
    final String formattedToDate = "$toDate 23:59:59";

    print("Querying from $formattedFromDate to $formattedToDate");

    return await db!.query(
      tableName,
      where: "dateTime BETWEEN ? AND ?",
      whereArgs: [formattedFromDate, formattedToDate],
    );
  }

  Future<List<Map<String, dynamic>>> getDataNon(String tableName) async {
    final db = await initializeDatabase();
    return await db!.query(tableName);
  }
}
