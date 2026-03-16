import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _db;

  DBHelper._init();

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB('borrow.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE borrow(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  itemName TEXT,
  borrower TEXT,
  borrowDate TEXT,
  returnDate TEXT,
  status TEXT,
  note TEXT
)
''');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final database = await db;
    return await database.insert('borrow', data);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final database = await db;
    return await database.query('borrow', orderBy: 'id DESC');
  }

  Future<int> update(Map<String, dynamic> data) async {
    final database = await db;
    return await database.update(
      'borrow',
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int> delete(int id) async {
    final database = await db;
    return await database.delete('borrow', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> fixInvalidDates() async {
    // กัน crash เฉยๆ
  }
}
