class ApiConfig {
  /// -------------------------------------------------------------------
  /// 📌 رابط السيرفر المحلي (API Base URL)
  /// -------------------------------------------------------------------
  /// إذا كنت تختبر على:
  /// 1. محاكي أندرويد (Android Emulator): 'http://10.0.2.2:8000/api'
  /// 2. تطبيق ويندوز أو متصفح أو محاكي iOS: 'http://127.0.0.1:8000/api'
  /// 3. سيرفر استضافة حقيقي مستقبلاً: 'https://your-domain.com/api'
  /// -------------------------------------------------------------------
  static const String baseUrl = 'https://lightseagreen-chinchilla-517199.hostingersite.com/api';

  /// رابط التخزين العام للملفات الصوتية والتفاسير
  static String get storageUrl {
    final root = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$root/storage';
  }
}
