import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/services/database_helper.dart';
import '../../data/models/tafsir_model.dart'; // assuming ayah model is exported or we can just fetch it

class SurahTafsirReaderScreen extends StatefulWidget {
  final int surahNumber;
  final Surah surah;

  const SurahTafsirReaderScreen({Key? key, required this.surahNumber, required this.surah}) : super(key: key);

  @override
  State<SurahTafsirReaderScreen> createState() => _SurahTafsirReaderScreenState();
}

class _SurahTafsirReaderScreenState extends State<SurahTafsirReaderScreen> {
  bool _isLoading = true;
  List<dynamic> _ayahsTafsir = []; // List of Ayah models from DatabaseHelper

  @override
  void initState() {
    super.initState();
    _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    final ayahs = await DatabaseHelper.instance.getAyahsBySurah(widget.surahNumber);
    setState(() {
      _ayahsTafsir = ayahs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final cardBg = isDark ? DesignTokens.darkCard : DesignTokens.lightCard;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تفسير سورة ${widget.surah.nameAr}',
            style: const TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          backgroundColor: cardBg,
          foregroundColor: textPrimary,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryAccent))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                itemCount: widget.surah.ayahs.length,
                itemBuilder: (context, index) {
                  final ayahObj = widget.surah.ayahs[index];
                  
                  // Find tafsir for this ayah
                  String tafsirText = 'التفسير غير متوفر حالياً لهذه الآية.';
                  if (_ayahsTafsir.isNotEmpty) {
                    try {
                      final t = _ayahsTafsir.firstWhere((a) => a.numberInSurah == ayahObj.ayahNumber);
                      if (t.tafsirMuyassar != null && t.tafsirMuyassar!.isNotEmpty) {
                        tafsirText = t.tafsirMuyassar!;
                      }
                    } catch (e) {
                      // ignore
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Ayah Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryAccent.withValues(alpha: 0.2), width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            ayahObj.ayah.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
                            style: TextStyle(
                              fontSize: 24, // Increased font size for better reading
                              height: 1.8,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              fontFamily: 'hafs', // Quraan font
                              package: 'flutter_quran', // CRITICAL for correct decoration rendering
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Tafsir Text
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            tafsirText,
                            style: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              fontSize: 16,
                              height: 1.6,
                              color: textPrimary.withOpacity(0.9),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        Divider(color: textPrimary.withOpacity(0.1)),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
