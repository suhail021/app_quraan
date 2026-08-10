import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/services/database_helper.dart';
import 'settings_screen.dart';
import 'reciters_screen.dart';
import 'tafsir_download_screen.dart';
import 'mushaf_reading_screen.dart';

class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({Key? key}) : super(key: key);

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return FlutterQuranScreen(
      useDefaultAppBar: false,
      onTafsirTap: (ayah) async {
        final surahs = await DatabaseHelper.instance.getAllSurahs();
        final surahModel = surahs.firstWhere((s) => s.number == ayah.surahNumber);
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => MushafReadingScreen(surah: surahModel, initialAyah: ayah.ayahNumber)
          ));
        }
      },
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white.withOpacity(0.95),
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        title: Text(
          'المصحف الشريف',
          style: TextStyle(
            fontFamily: DesignTokens.fontCairo,
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Builder(builder: (innerContext) => _buildDrawer(isDark, textPrimary, innerContext)),
    );
  }

  Widget _buildDrawer(bool isDark, Color textPrimary, BuildContext innerContext) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: DesignTokens.lightPrimaryAccent,
            width: double.infinity,
            child: Column(
              children: [
                Icon(Icons.menu_book, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'فهرس السور',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontCairo,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 114,
              itemBuilder: (context, index) {
                final surahNum = index + 1;
                final surah = FlutterQuran().getSurah(surahNum);
                final startJozz = surah.ayahs.first.jozz;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: DesignTokens.lightPrimaryAccent.withOpacity(0.1),
                    child: Text(
                      '$surahNum',
                      style: const TextStyle(
                        fontFamily: DesignTokens.fontCairo,
                        color: DesignTokens.lightPrimaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'سورة ${surah.nameAr}',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontCairo,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'الجزء $startJozz • صفحة ${surah.startPage}',
                    style: TextStyle(
                      fontFamily: DesignTokens.fontCairo,
                      fontSize: 13,
                      color: textPrimary.withOpacity(0.6),
                    ),
                  ),
                  onTap: () {
                    // Close the drawer using inner context
                    Navigator.pop(innerContext);
                    // Navigate to Surah
                    FlutterQuran().navigateToSurah(surahNum);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Navigation to other sections using Root Navigator
          ListTile(
            leading: const Icon(Icons.record_voice_over, color: DesignTokens.lightPrimaryAccent),
            title: Text('القراء', style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary)),
            onTap: () {
              Navigator.pop(innerContext); // Close Drawer
              Navigator.of(innerContext, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const RecitersScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.download, color: DesignTokens.lightPrimaryAccent),
            title: Text('تحميل التفاسير', style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary)),
            onTap: () {
              Navigator.pop(innerContext); // Close Drawer
              Navigator.of(innerContext, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const TafsirDownloadScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: DesignTokens.lightPrimaryAccent),
            title: Text('الإعدادات', style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary)),
            onTap: () {
              Navigator.pop(innerContext); // Close Drawer
              Navigator.of(innerContext, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
