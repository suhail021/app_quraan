import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/surah_model.dart';
import '../../data/services/database_helper.dart';
import 'book_reading_screen.dart';

class MushafReadingScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;

  const MushafReadingScreen({Key? key, required this.surah, this.initialAyah}) : super(key: key);

  @override
  State<MushafReadingScreen> createState() => _MushafReadingScreenState();
}

class _MushafReadingScreenState extends State<MushafReadingScreen> {
  int? _selectedAyahNumber;
  List<Ayah> _ayahs = [];
  bool _isLoading = true;
  double _fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    _selectedAyahNumber = widget.initialAyah;
    _loadAyahs();
  }

  Future<void> _loadAyahs() async {
    final list = await DatabaseHelper.instance.getAyahsBySurah(widget.surah.number);
    setState(() {
      _ayahs = list;
      _isLoading = false;
    });
  }

  void _toggleAyahSelection(int ayahNumber) {
    setState(() {
      if (_selectedAyahNumber == ayahNumber) {
        _selectedAyahNumber = null; // طي التفسير لو ضغط عليها مرة ثانية
      } else {
        _selectedAyahNumber = ayahNumber; // فتح التفسير للآية الجديدة وطي السابق
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DesignTokens.darkBg : DesignTokens.lightBg;
    final highlightColor = isDark ? DesignTokens.darkAyahHighlight : DesignTokens.lightAyahHighlight;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'سورة ${widget.surah.nameAr}',
              style: TextStyle(
                fontFamily: DesignTokens.fontCairo,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textPrimary,
              ),
            ),
            Text(
              '${widget.surah.revelationType == "Meccan" ? "مكية" : "مدنية"} - ${widget.surah.totalAyahs} آيات',
              style: TextStyle(
                fontFamily: DesignTokens.fontCairo,
                fontSize: 11,
                color: textPrimary.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.book, color: goldAccent),
            label: Text(
              'وضع الكتاب',
              style: TextStyle(color: textPrimary, fontFamily: DesignTokens.fontCairo),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize == 24.0 ? 28.0 : (_fontSize == 28.0 ? 20.0 : 24.0);
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // إطار زخرفي هادئ لعنوان السورة
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: goldAccent.withOpacity(0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: DesignTokens.fontUthmanic,
                        fontSize: _fontSize - 2,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),

                // الآيات والتفسير الـ Inline
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _ayahs.length,
                    itemBuilder: (context, index) {
                      final ayah = _ayahs[index];
                      final isSelected = _selectedAyahNumber == ayah.numberInSurah;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // الآية مع تظليل 8-10% عند الاختيار
                          GestureDetector(
                            onTap: () => _toggleAyahSelection(ayah.numberInSurah),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? highlightColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    ayah.textUthmanic,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontFamily: DesignTokens.fontUthmanic,
                                      fontSize: _fontSize,
                                      height: 1.9,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // الدائرة الزخرفية لرقم الآية
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: goldAccent.withOpacity(0.6)),
                                    ),
                                    child: Text(
                                      '${ayah.numberInSurah}',
                                      style: TextStyle(
                                        fontFamily: DesignTokens.fontCairo,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: goldAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // التفسير الـ Inline Slide-Down (Accordion)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: isSelected
                                ? Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? highlightColor.withOpacity(0.6) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: goldAccent.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.menu_book, size: 14, color: goldAccent),
                                            const SizedBox(width: 6),
                                            Text(
                                              'التفسير الميسر (آية ${ayah.numberInSurah})',
                                              style: TextStyle(
                                                fontFamily: DesignTokens.fontCairo,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: goldAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          ayah.tafsirMuyassar ?? 'التفسير غير متوفر لهذه الآية حالياً.',
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontFamily: DesignTokens.fontCairo,
                                            fontSize: 14,
                                            height: 1.6,
                                            color: textPrimary.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
