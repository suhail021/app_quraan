import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  String _currentDbName = 'quran_app.db';

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDB(_currentDbName);
    return _database;
  }

  /// 📌 تغيير قاعدة البيانات النشطة (مفيد عند تغيير التفسير)
  Future<void> changeDatabase(String dbName) async {
    if (dbName == 'tafsir_muyassar.db') dbName = 'quran_app.db';
    if (_currentDbName == dbName && _database != null) return;
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _currentDbName = dbName;
    await database; // إعادة التهيئة
  }

  /// 📌 التحقق مما إذا كان التفسير محملاً محلياً
  Future<bool> isTafsirDownloaded(String key) async {
    if (key == 'muyassar') return true; // الميسر مدمج كافتراضي
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tafsir_$key.db');
    return await databaseExists(path);
  }

  /// 📌 تحميل وفك ضغط قاعدة بيانات التفسير
  Future<bool> downloadAndExtractTafsir(String key, String zipUrl) async {
    try {
      final dbPath = await getDatabasesPath();
      final targetDbPath = join(dbPath, 'tafsir_$key.db');
      
      // تحميل الملف المضغوط إلى مجلد مؤقت
      final tempDir = await getTemporaryDirectory();
      final zipPath = join(tempDir.path, 'tafsir_$key.zip');
      
      final dio = Dio();
      await dio.download(zipUrl, zipPath);
      
      // فك الضغط
      final bytes = File(zipPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (final file in archive) {
        if (file.isFile && file.name.endsWith('.db')) {
          final data = file.content as List<int>;
          File(targetDbPath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
          break; // نفترض أن هناك ملف DB واحد
        }
      }
      
      // تنظيف الملف المؤقت
      File(zipPath).deleteSync();
      return true;
    } catch (e) {
      print('Error downloading tafsir: $e');
      return false; // فشل (بسبب الإنترنت أو غيره)
    }
  }

  Future<Database?> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      final exists = await databaseExists(path);

      if (!exists) {
        // نسخ قاعدة البيانات المدمجة من assets لو كانت موجودة
        try {
          final data = await rootBundle.load('assets/database/$filePath');
          final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(path).writeAsBytes(bytes, flush: true);
        } catch (e) {
          print('Asset database not loaded yet, using mock/dynamic store.');
          return null;
        }
      }

      return await openDatabase(path, readOnly: true);
    } catch (e) {
      print('Database init error: $e');
      return null;
    }
  }

  /// الحصول على كل السور
  Future<List<Surah>> getAllSurahs() async {
    final db = await database;
    if (db == null) {
      return _getMockSurahs();
    }

    try {
      final maps = await db.query('surahs', orderBy: 'number ASC');
      return maps.map((m) => Surah.fromMap(m)).toList();
    } catch (e) {
      return _getMockSurahs();
    }
  }

  /// الحصول على آيات سورة معينة مع التفسير الميسر
  Future<List<Ayah>> getAyahsBySurah(int surahNumber) async {
    final db = await database;
    if (db == null) {
      return _getMockAyahs(surahNumber);
    }

    try {
      final maps = await db.query(
        'ayahs',
        where: 'surah_number = ?',
        whereArgs: [surahNumber],
        orderBy: 'number_in_surah ASC',
      );
      return maps.map((m) => Ayah.fromMap(m)).toList();
    } catch (e) {
      return _getMockAyahs(surahNumber);
    }
  }

  /// 📌 حفظ موضع القراءة الأخير تلقائياً (رقم السورة ورقم الصفحة)
  Future<void> saveLastReadingPosition(int surahNumber, int pageNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_surah_number', surahNumber);
      await prefs.setInt('last_page_number', pageNumber);
    } catch (e) {
      print('Error saving reading position: $e');
    }
  }

  /// 📌 استرجاع موضع القراءة الأخير
  Future<Map<String, int>> getLastReadingPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'surah_number': prefs.getInt('last_surah_number') ?? 1,
        'page_number': prefs.getInt('last_page_number') ?? 1,
      };
    } catch (e) {
      return {'surah_number': 1, 'page_number': 1};
    }
  }

  /// بيانات افتراضية توضيحية تجنباً لأي توقف للبرنامج
  List<Surah> _getMockSurahs() {
    return [
      Surah(number: 1, nameAr: 'الفاتحة', revelationType: 'Meccan', totalAyahs: 7),
      Surah(number: 2, nameAr: 'البقرة', revelationType: 'Medinan', totalAyahs: 286),
      Surah(number: 3, nameAr: 'آل عمران', revelationType: 'Medinan', totalAyahs: 200),
      Surah(number: 112, nameAr: 'الإخلاص', revelationType: 'Meccan', totalAyahs: 4),
      Surah(number: 113, nameAr: 'الفلق', revelationType: 'Meccan', totalAyahs: 5),
      Surah(number: 114, nameAr: 'الناس', revelationType: 'Meccan', totalAyahs: 6),
    ];
  }

  List<Ayah> _getMockAyahs(int surahNumber) {
    if (surahNumber == 1) {
      return [
        Ayah(numberInSurah: 1, surahNumber: 1, textUthmanic: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', tafsirMuyassar: 'سورة افتتح بها الكتاب، وتسمى أم الكتاب لأنها تجمع مقاصده.', pageNumber: 1, juzNumber: 1),
        Ayah(numberInSurah: 2, surahNumber: 1, textUthmanic: 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ', tafsirMuyassar: 'الثناء الكامل لله تعالى وحده رب كل شيء وخالقه ومدبره.', pageNumber: 1, juzNumber: 1),
        Ayah(numberInSurah: 3, surahNumber: 1, textUthmanic: 'ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', tafsirMuyassar: 'الذي وسعت رحمته كل شيء، والخاصة بالمؤمنين.', pageNumber: 1, juzNumber: 1),
        Ayah(numberInSurah: 4, surahNumber: 1, textUthmanic: 'مَٰلِكِ يَوۡمِ ٱلدِّينِ', tafsirMuyassar: 'المالك والمترئس ليوم الحساب والجزاء.', pageNumber: 1, juzNumber: 1),
        Ayah(numberInSurah: 5, surahNumber: 1, textUthmanic: 'إِيَّاكَ نَعۡبُدُ وَإِيَّاكَ نَسۡتَعِينُ', tafsirMuyassar: 'نخصك وحدك بالعبادة ونخصك وحدك بطلب الإعانة.', pageNumber: 1, juzNumber: 1),
        Ayah(numberInSurah: 6, surahNumber: 1, textUthmanic: 'ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ', tafsirMuyassar: 'وفقنا وسددنا وادر بنا في الطريق المستقيم الثابت.', pageNumber: 1, juzNumber: 1),
        Ayah(numberInSurah: 7, surahNumber: 1, textUthmanic: 'صِرَٰطَ ٱلَّذِينَ أَنۡعَمۡتَ عَلَيۡهِمۡ غَيۡرِ ٱلۡمَغۡضُوبِ عَلَيۡهِمۡ وَلَا ٱلضَّآلِّينَ', tafsirMuyassar: 'طريق الأنبياء والصديقين، غير المغضوب عليهم وهم اليهود ومن تبعهم، ولا الضالين وهم النصارى ومن سلك سبيلهم.', pageNumber: 1, juzNumber: 1),
      ];
    }
    return [
      Ayah(numberInSurah: 1, surahNumber: surahNumber, textUthmanic: 'قُلۡ هُوَ ٱللَّهُ أَحَدٌ', tafsirMuyassar: 'قل أيها الرسول: هو الله الواحد الأحد الذي لا شريك له.', pageNumber: 604, juzNumber: 30),
      Ayah(numberInSurah: 2, surahNumber: surahNumber, textUthmanic: 'ٱللَّهُ ٱلصَّمَدُ', tafsirMuyassar: 'الله الذي يقصد في الحوائج كلها، الكامل في صفاته.', pageNumber: 604, juzNumber: 30),
    ];
  }
}
