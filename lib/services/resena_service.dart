import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/resena.dart';

class ResenaService {
  static Future<Database>? _database;

  Future<Database> get database {
    return _database ??= _abrirBaseDeDatos();
  }

  Future<Database> _abrirBaseDeDatos() async {
    final carpeta = await getDatabasesPath();

return openDatabase(
  join(carpeta, 'recetas.db'),
  version: 2,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE resenas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receta_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        comentario TEXT NOT NULL
      )
    ''');
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE resenas
        ADD COLUMN nombre TEXT NOT NULL DEFAULT 'Sin nombre'
      ''');
    }
  },
);
  }

  Future<void> agregarResena(Resena resena) async {
    final db = await database;
    await db.insert('resenas', resena.toMap());
  }

  Future<List<Resena>> obtenerResenas(int recetaId) async {
    final db = await database;

    final filas = await db.query(
      'resenas',
      where: 'receta_id = ?',
      whereArgs: [recetaId],
      orderBy: 'id DESC',
    );

    return filas.map((fila) => Resena.fromMap(fila)).toList();
  }
}