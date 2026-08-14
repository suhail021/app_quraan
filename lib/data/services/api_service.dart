import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../models/reciter_model.dart';
import '../models/tafsir_model.dart';

class ApiService {
  /// جلب قائمة كل القراء وسورهم من الباك إند
  Future<List<Reciter>> fetchReciters() async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/reciters'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          final List list = decoded['data'] ?? [];
          return list.map((json) => Reciter.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching reciters: $e');
      return [];
    }
  }

  /// جلب تفاصيل قارئ معين بواسطة الـ slug
  Future<Reciter?> fetchReciterBySlug(String slug) async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/reciters/$slug'));

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

  /// جلب قائمة التفاسير المتاحة للتحميل
  Future<List<TafsirEdition>> fetchTafsirs() async {
    try {
      final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/tafsirs'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success') {
          final List list = decoded['data'] ?? [];
          return list.map((json) => TafsirEdition.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching tafsirs: $e');
      return [];
    }
  }
}
