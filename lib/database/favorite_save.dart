import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'favorites.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorite (
        id INTEGER PRIMARY KEY,
        title TEXT,
        posterPath TEXT,
        overview TEXT,
        voteAverage REAL,
        releaseDate TEXT,
        backdropPath TEXT,
        originalLanguage TEXT,
        genreIds TEXT,
        adult INTEGER,
        originalTitle TEXT,
        mediaType TEXT,
        voteCount INTEGER,
        video INTEGER,
        popularity REAL
      )
    ''');
  }

  Future<int> insertFavorite(Movie favorite) async {
    final dbClient = await db;
    int result = await dbClient.insert(
      'favorite',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<List<Movie>> getFavorites() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('favorite');
    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  Future<int> deleteFavorite(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'favorite',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isFavorite(int id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'favorite',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }
}