import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/tafsir_model.dart';
import '../../data/services/api_service.dart';
import 'surah_tafsir_reader_screen.dart';

class TafsirSurahsScreen extends StatefulWidget {
  const TafsirSurahsScreen({Key? key}) : super(key: key);

  @override
  State<TafsirSurahsScreen> createState() => _TafsirSurahsScreenState();
}

class _TafsirSurahsScreenState extends State<TafsirSurahsScreen> {
  final ApiService _apiService = ApiService();
  
  String _searchQuery = '';
  List<Surah> _allSurahs = [];
  
  List<TafsirEdition> _tafsirs = [];
  TafsirEdition? _selectedTafsir;
  bool _isLoadingTafsirs = true;

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= 114; i++) {
      _allSurahs.add(FlutterQuran().getSurah(i));
    }
    _loadTafsirs();
  }

  Future<void> _loadTafsirs() async {
    final list = await _apiService.fetchTafsirs();
    if (mounted) {
      setState(() {
        _tafsirs = list;
        if (list.isNotEmpty) {
          // Default to the bundled/default one, or just the first
          _selectedTafsir = list.firstWhere((t) => t.isBundledDefault, orElse: () => list.first);
        }
        _isLoadingTafsirs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F7F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final cardBg = isDark ? const Color(0xFF252538) : Colors.white;

    final filteredSurahs = _allSurahs.where((s) => s.nameAr.contains(_searchQuery)).toList();

    return Scaffold(
      backgroundColor: primaryAccent, // يجعل شريط المهام (Status Bar) يأخذ نفس اللون
      body: SafeArea(
        bottom: false,
        child: Container(
          color: bgColor, // خلفية باقي الشاشة
          child: Column(
            children: [
            // Header Section with Gradient
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 24, left: 8, right: 16),
              decoration: BoxDecoration(
                color: primaryAccent, // لون موحد بدل المدرج
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // زر الرجوع
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _isLoadingTafsirs
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : _tafsirs.isEmpty
                                ? const Text(
                                    'التفسير الميسر',
                                    style: TextStyle(
                                      fontFamily: DesignTokens.fontCairo,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<TafsirEdition>(
                                      value: _selectedTafsir,
                                      icon: const SizedBox.shrink(),
                                      iconSize: 0.0,
                                      dropdownColor: primaryAccent.withOpacity(0.95),
                                      isExpanded: true,
                                      selectedItemBuilder: (BuildContext context) {
                                        return _tafsirs.map<Widget>((TafsirEdition item) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.nameAr,
                                                  style: const TextStyle(
                                                    fontFamily: DesignTokens.fontCairo,
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 32),
                                            ],
                                          );
                                        }).toList();
                                      },
                                      onChanged: (TafsirEdition? newValue) {
                                        if (newValue != null && newValue.id != _selectedTafsir?.id) {
                                          setState(() {
                                            _selectedTafsir = newValue;
                                          });
                                        }
                                      },
                                      items: _tafsirs.map<DropdownMenuItem<TafsirEdition>>((TafsirEdition t) {
                                        return DropdownMenuItem<TafsirEdition>(
                                          value: t,
                                          child: Text(
                                            t.nameAr,
                                            style: const TextStyle(
                                              fontFamily: DesignTokens.fontCairo,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Glassmorphic Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            style: const TextStyle(fontFamily: DesignTokens.fontCairo, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن سورة للتفسير...',
                              hintStyle: TextStyle(fontFamily: DesignTokens.fontCairo, color: Colors.white.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // List Section
            Expanded(
              child: filteredSurahs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد سورة بهذا الاسم',
                            style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: filteredSurahs.length,
                      itemBuilder: (context, index) {
                        final surah = filteredSurahs[index];
                        final surahNumber = _allSurahs.indexOf(surah) + 1; // get original 1-based index

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 44,
                              height: 44,
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
                                  fontSize: 16,
                                  color: primaryAccent,
                                ),
                              ),
                            ),
                            title: Text(
                              'سورة ${surah.nameAr}',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'عدد آياتها: ${surah.ayahs.length}',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontSize: 13,
                                color: textSecondary,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryAccent.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: primaryAccent),
                            ),
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
      ),
    );
  }
}
