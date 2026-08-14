import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../core/theme/design_tokens.dart';
import 'surah_tafsir_reader_screen.dart';

class TafsirSurahsScreen extends StatefulWidget {
  const TafsirSurahsScreen({Key? key}) : super(key: key);

  @override
  State<TafsirSurahsScreen> createState() => _TafsirSurahsScreenState();
}

class _TafsirSurahsScreenState extends State<TafsirSurahsScreen> {
  String _searchQuery = '';
  List<Surah> _allSurahs = [];

  @override
  void initState() {
    super.initState();
    // Load all surahs
    for (int i = 1; i <= 114; i++) {
      _allSurahs.add(FlutterQuran().getSurah(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final cardBg = isDark ? DesignTokens.darkCard : DesignTokens.lightCard;

    final filteredSurahs = _allSurahs.where((s) => s.nameAr.contains(_searchQuery)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('التفسير الميسر', style: TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: cardBg,
        foregroundColor: textPrimary,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'ابحث عن سورة للتفسير...',
                  hintStyle: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: primaryAccent),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredSurahs.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد نتائج للبحث',
                        style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSurahs.length,
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        final surahNumber = _allSurahs.indexOf(surah) + 1; // get original 1-based index

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryAccent.withOpacity(0.1)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryAccent.withOpacity(0.1),
                              ),
                              child: Text(
                                '$surahNumber',
                                style: TextStyle(
                                  fontFamily: DesignTokens.fontCairo,
                                  fontWeight: FontWeight.bold,
                                  color: primaryAccent,
                                ),
                              ),
                            ),  
                            title: Text(
                              'سورة ${surah.nameAr}',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'آياتها: ${surah.ayahs.length}',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontSize: 12,
                                color: textPrimary.withOpacity(0.6),
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SurahTafsirReaderScreen(surahNumber: surahNumber, surah: surah),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
