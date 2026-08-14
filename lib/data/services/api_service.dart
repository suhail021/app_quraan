import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../models/reciter_model.dart';
import '../models/tafsir_model.dart';

class ApiService {
  static const String _cachedRecitersKey = 'cached_reciters';
  static const String _cachedTafsirsKey = 'cached_tafsirs';

  /// جلب قائمة كل القراء وسورهم من الباك إند مع التخزين المؤقت
  Future<List<Reciter>> fetchReciters() async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/reciters'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          // حفظ البيانات محلياً (Caching)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cachedRecitersKey, response.body);

          final List list = decoded['data'] ?? [];
          return list.map((json) => Reciter.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Network error fetching reciters, falling back to cache: $e');
    }

    // استرجاع الكاش إذا فشل الاتصال بالإنترنت
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_cachedRecitersKey);
      if (cachedStr != null) {
        final decoded = json.decode(cachedStr);
        if (decoded['status'] == 'success') {
          final List list = decoded['data'] ?? [];
          return list.map((json) => Reciter.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error loading cached reciters: $e');
    }

    return [];
  }

  /// جلب تفاصيل قارئ معين بواسطة الـ slug
  Future<Reciter?> fetchReciterBySlug(String slug) async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/reciters/$slug'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          return Reciter.fromJson(decoded['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching reciter detail: $e');
      return null;
    }
  }

  /// جلب قائمة التفاسير المتاحة للتحميل مع التخزين المؤقت
  Future<List<TafsirEdition>> fetchTafsirs() async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/tafsirs'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          // حفظ البيانات محلياً (Caching)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cachedTafsirsKey, response.body);

          final List list = decoded['data'] ?? [];
          return list.map((json) => TafsirEdition.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Network error fetching tafsirs, falling back to cache: $e');
    }

    // استرجاع الكاش إذا فشل الاتصال بالإنترنت
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_cachedTafsirsKey);
      if (cachedStr != null) {
        final decoded = json.decode(cachedStr);
        if (decoded['status'] == 'success') {
          final List list = decoded['data'] ?? [];
          return list.map((json) => TafsirEdition.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error loading cached tafsirs: $e');
    }

    // إذا لم يكن هناك إنترنت ولم يكن هناك كاش، نرجع التفسير الافتراضي
    return [
      TafsirEdition(
        id: 1,
        key: 'muyassar',
        nameAr: 'التفسير الميسر',
        isBundledDefault: true,
        version: '1.0',
        downloadZipUrl: '',
      ),
    ];
  }
}
