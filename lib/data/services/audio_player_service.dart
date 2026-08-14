import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:dio/dio.dart';

/// السور المُدمجة مباشرة داخل التطبيق (لا تحتاج إنترنت أبداً)
/// الفاتحة (001) + البقرة (002) + جزء عمّ (078 - 114) = 39 سورة
const Set<int> kBundledSurahs = {
  1, 2,
  78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
  91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102,
  103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114,
};

enum AudioSourceType { bundled, localFile, streaming }

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();

  bool _isPlaying = false;
  String _currentSurahName = '';
  String _currentReciterName = '';
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AudioSourceType _sourceType = AudioSourceType.streaming;
  
  // Download tracking
  final Set<String> _downloadingKeys = {};
  final Set<String> _downloadedKeys = {};

  bool get isPlaying => _isPlaying;
  String get currentSurahName => _currentSurahName;
  String get currentReciterName => _currentReciterName;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioSourceType get sourceType => _sourceType;

  /// هل السورة مدمجة بالتطبيق من البداية؟
  bool get isOffline => _sourceType != AudioSourceType.streaming;

  /// وصف نوع المصدر (يظهر في المشغّل الكامل)
  String get sourceLabel {
    switch (_sourceType) {
      case AudioSourceType.bundled:
        return 'مدمج بالتطبيق — أوفلاين';
      case AudioSourceType.localFile:
        return 'محمّل محلياً — أوفلاين';
      case AudioSourceType.streaming:
        return 'بث مباشر عبر الإنترنت';
    }
  }

  AudioPlayerService() {
    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
    _initDownloadedFiles();
  }

  Future<void> _initDownloadedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(p.join(dir.path, 'downloads'));
      if (await downloadsDir.exists()) {
        final entities = downloadsDir.listSync(recursive: true);
        for (var entity in entities) {
          if (entity is File && entity.path.endsWith('.mp3')) {
            // path format: downloads/SafeReciterName/001.mp3
            final parts = p.split(entity.path);
            if (parts.length >= 2) {
              final surahNumStr = p.basenameWithoutExtension(entity.path);
              final safeReciter = parts[parts.length - 2];
              final surahNum = int.tryParse(surahNumStr);
              if (surahNum != null) {
                _downloadedKeys.add('${safeReciter}_$surahNum');
              }
            }
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading downloaded files: $e');
    }
  }

  String _getDownloadKey(String reciterName, int surahNumber) {
    final safeReciterName = reciterName.replaceAll(RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'), '_');
    return '${safeReciterName}_$surahNumber';
  }

  bool isDownloading(String reciterName, int surahNumber) {
    return _downloadingKeys.contains(_getDownloadKey(reciterName, surahNumber));
  }

  bool isDownloaded(String reciterName, int surahNumber) {
    if (kBundledSurahs.contains(surahNumber)) return true;
    return _downloadedKeys.contains(_getDownloadKey(reciterName, surahNumber));
  }

  Future<String> _getSurahLocalPath(String reciterName, int surahNumber) async {
    final dir = await getApplicationDocumentsDirectory();
    final paddedNum = surahNumber.toString().padLeft(3, '0');
    final safeReciterName = reciterName.replaceAll(RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'), '_');
    return p.join(dir.path, 'downloads', safeReciterName, '$paddedNum.mp3');
  }

  Future<void> downloadAndPlaySurah({
    required int surahNumber,
    required String surahName,
    required String reciterName,
    required String streamUrl,
  }) async {
    if (isDownloaded(reciterName, surahNumber)) {
      // Already downloaded or bundled, play directly
      final localPath = await _getSurahLocalPath(reciterName, surahNumber);
      await playSurah(
        surahNumber: surahNumber,
        surahName: surahName,
        reciterName: reciterName,
        localFilePath: kBundledSurahs.contains(surahNumber) ? null : localPath,
      );
      return;
    }

    final key = _getDownloadKey(reciterName, surahNumber);
    if (_downloadingKeys.contains(key)) return; // Already downloading

    _downloadingKeys.add(key);
    notifyListeners();

    try {
      final localPath = await _getSurahLocalPath(reciterName, surahNumber);
      final file = File(localPath);
      if (!(await file.parent.exists())) {
        await file.parent.create(recursive: true);
      }

      await _dio.download(streamUrl, localPath);
      
      _downloadedKeys.add(key);
      _downloadingKeys.remove(key);
      notifyListeners();

      // Autoplay after download
      await playSurah(
        surahNumber: surahNumber,
        surahName: surahName,
        reciterName: reciterName,
        localFilePath: localPath,
      );
    } catch (e) {
      debugPrint('Download failed: $e');
      _downloadingKeys.remove(key);
      notifyListeners();
    }
  }

  /// تشغيل سورة — يختار المصدر تلقائياً بالأولوية:
  /// 1. Bundled asset (مدمج) → 2. Local file (محمّل) → 3. Stream (إنترنت)
  Future<void> playSurah({
    required int surahNumber,
    required String surahName,
    required String reciterName,
    String? streamUrl,
    String? localFilePath,
  }) async {
    _currentSurahName = 'سورة $surahName';
    _currentReciterName = reciterName;
    notifyListeners();

    final paddedNum = surahNumber.toString().padLeft(3, '0');

    try {
      // ── الأولوية 1: الملف مُدمج في التطبيق ──────────────────────────
      if (kBundledSurahs.contains(surahNumber)) {
        final assetPath = 'assets/audio/bundled/$paddedNum.mp3';
        // نسخ الـ asset لمساحة مؤقتة لأن just_audio يحتاج ملف حقيقي
        final tempFile = await _extractAssetToTemp(assetPath, paddedNum);
        if (tempFile != null) {
          await _player.setFilePath(tempFile.path);
          _sourceType = AudioSourceType.bundled;
          await _player.play();
          notifyListeners();
          return;
        }
      }

      // ── الأولوية 2: ملف محمّل محلياً بالجهاز ───────────────────────
      if (localFilePath != null && await File(localFilePath).exists()) {
        await _player.setFilePath(localFilePath);
        _sourceType = AudioSourceType.localFile;
        await _player.play();
        notifyListeners();
        return;
      }

      // ── الأولوية 3: البث المباشر من الإنترنت ────────────────────────
      if (streamUrl != null && streamUrl.isNotEmpty) {
        await _player.setUrl(streamUrl);
        _sourceType = AudioSourceType.streaming;
        await _player.play();
        notifyListeners();
        return;
      }

      debugPrint('لا يوجد مصدر صوتي متاح لسورة $surahName');
    } catch (e) {
      debugPrint('خطأ بتشغيل سورة $surahName: $e');
    }
  }

  /// استخراج ملف الـ asset إلى مجلد مؤقت (ضروري لـ just_audio)
  Future<File?> _extractAssetToTemp(String assetPath, String paddedNum) async {
    try {
      final dir = await getTemporaryDirectory();
      final tempPath = p.join(dir.path, 'quran_audio_$paddedNum.mp3');
      final tempFile = File(tempPath);

      // لو الملف موجود مسبقاً بالمؤقت استخدمه مباشرة
      if (await tempFile.exists()) return tempFile;

      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    } catch (e) {
      debugPrint('خطأ استخراج asset $assetPath: $e');
      return null;
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentSurahName = '';
    _currentReciterName = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
