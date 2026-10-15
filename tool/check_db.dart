import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final dbPath = '${Directory.current.path}/assets/db/sunan_ibn_majah.db';
  final db = await factory.openDatabase(dbPath, options: OpenDatabaseOptions(readOnly: true));

  // Check column type
  final pragma = await db.rawQuery("PRAGMA table_info(hadiths)");
  for (final r in pragma) {
    print('Column: ${r['name']}, Type: ${r['type']}');
  }

  // Check hadith_number = '122' vs hadith_number = 122
  print('\n--- String match ---');
  final s = await db.rawQuery('SELECT id, chapter_id, hadith_number FROM hadiths WHERE hadith_number = ?', ['122']);
  for (final r in s) {
    print('  id=${r['id']}, ch=${r['chapter_id']}, num=${r['hadith_number']}');
  }

  print('\n--- Integer match ---');
  final i = await db.rawQuery('SELECT id, chapter_id, hadith_number FROM hadiths WHERE hadith_number = ?', [122]);
  for (final r in i) {
    print('  id=${r['id']}, ch=${r['chapter_id']}, num=${r['hadith_number']}');
  }

  // Check typeof
  print('\n--- typeof hadith_number for first row ---');
  final t = await db.rawQuery('SELECT typeof(hadith_number) as t, hadith_number FROM hadiths LIMIT 3');
  for (final r in t) {
    print('  type=${r['t']}, value=${r['hadith_number']}');
  }

  // Check getHadithIndexWithinChapter for hadith 122
  print('\n--- Index within chapter for hadith 122 ---');
  final idx = await db.rawQuery(
    'SELECT COUNT(*) as c FROM hadiths WHERE chapter_id = ? AND CAST(hadith_number AS FLOAT) < CAST(? AS FLOAT)',
    [1, '122']
  );
  print('  Index: ${idx.first['c']}');

  // What hadith is at that index?
  final atIdx = await db.rawQuery(
    'SELECT id, hadith_number FROM hadiths WHERE chapter_id = 1 ORDER BY hadith_number ASC LIMIT 1 OFFSET ?',
    [idx.first['c']]
  );
  for (final r in atIdx) {
    print('  Hadith at that index: id=${r['id']}, num=${r['hadith_number']}');
  }

  await db.close();
}