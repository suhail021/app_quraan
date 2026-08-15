import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../data/services/database_helper.dart';
import '../../core/theme/design_tokens.dart';
import '../screens/surah_tafsir_reader_screen.dart';
class AyahTafsirBottomSheet extends StatefulWidget {
  final Ayah initialAyah;

  const AyahTafsirBottomSheet({Key? key, required this.initialAyah}) : super(key: key);

  @override
  State<AyahTafsirBottomSheet> createState() => _AyahTafsirBottomSheetState();
}

class _AyahTafsirBottomSheetState extends State<AyahTafsirBottomSheet> {
  static List<Ayah>? _allAyahs;
  late PageController _pageController;
  late int _currentIndex;
  
  // Cache for loaded tafsir text by index
  final Map<int, String> _tafsirCache = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize the flattened list of all Ayahs once
    if (_allAyahs == null) {
      _allAyahs = [];
      for (int i = 1; i <= 114; i++) {
        _allAyahs!.addAll(FlutterQuran().getSurah(i).ayahs);
      }
    }

    // Find the initial index
    _currentIndex = _allAyahs!.indexWhere((a) => a.id == widget.initialAyah.id);
    if (_currentIndex == -1) _currentIndex = 0; // Fallback

    _pageController = PageController(initialPage: _currentIndex);
    
    _fetchTafsir(_currentIndex);
    _updateHighlight(_allAyahs![_currentIndex]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    FlutterQuran().removeBookmark(bookmarkId: 3);
    super.dispose();
  }

  void _updateHighlight(Ayah ayah) {
    FlutterQuran().removeBookmark(bookmarkId: 3);
    FlutterQuran().setBookmark(
        ayahId: ayah.id, page: ayah.page, bookmarkId: 3);
    
    if (FlutterQuran().getCurrentPageNumber() != ayah.page) {
      FlutterQuran().navigateToPage(ayah.page);
    }
  }

  Future<void> _fetchTafsir(int index) async {
    if (_tafsirCache.containsKey(index)) return;
    
    final ayah = _allAyahs![index];
    
    // UI Loading state is just missing key in cache (handled in build)
    final ayahsInSurah = await DatabaseHelper.instance.getAyahsBySurah(ayah.surahNumber);
    final ayahModel = ayahsInSurah.firstWhere(
      (a) => a.numberInSurah == ayah.ayahNumber, 
      orElse: () => ayahsInSurah.first
    );
    
    if (mounted) {
      setState(() {
        _tafsirCache[index] = ayahModel.tafsirMuyassar ?? 'لا يتوفر تفسير لهذه الآية حالياً.';
      });
    }
  }

  void _onPageChanged(int index) {
    final ayah = _allAyahs![index];
    setState(() {
      _currentIndex = index;
    });
    _updateHighlight(ayah);
    _fetchTafsir(index);
    
    // Pre-fetch next and previous tafsirs for smooth swiping
    if (index < _allAyahs!.length - 1) _fetchTafsir(index + 1);
    if (index > 0) _fetchTafsir(index - 1);
  }

  void _toggleBookmark(Ayah currentAyah) {
    final bookmarks = FlutterQuran().getAllBookmarks();
    final mainBookmark = bookmarks.isNotEmpty ? bookmarks.first : null;
    
    if (mainBookmark != null) {
      if (mainBookmark.ayahId == currentAyah.id) {
        FlutterQuran().removeBookmark(bookmarkId: mainBookmark.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إزالة العلامة المرجعية')));
      } else {
        FlutterQuran().setBookmark(
          ayahId: currentAyah.id, 
          page: currentAyah.page, 
          bookmarkId: mainBookmark.id
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ العلامة المرجعية بنجاح')));
      }
      setState(() {});
    }
  }

  void _copyAyah(Ayah currentAyah) {
    Clipboard.setData(ClipboardData(text: '﴿${currentAyah.ayah}﴾')).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الآية للحافظة')));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ayah = _allAyahs![_currentIndex];
    final isBookmarked = FlutterQuran().getAllBookmarks().isNotEmpty 
        && FlutterQuran().getAllBookmarks().first.ayahId == ayah.id;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.56,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            
            Flexible(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  // RTL: drag right -> positive velocity (previous for LTR, next for RTL)
                  if (details.primaryVelocity! > 300) {
                    if (_currentIndex < _allAyahs!.length - 1) {
                      _onPageChanged(_currentIndex + 1);
                    }
                  } else if (details.primaryVelocity! < -300) {
                    if (_currentIndex > 0) {
                      _onPageChanged(_currentIndex - 1);
                    }
                  }
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header: Title and Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'تفسير الآية ${ayah.ayahNumber} - سورة ${ayah.surahNameAr}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 18, 
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.menu_book_rounded),
                                  color: colorScheme.primary,
                                  tooltip: 'تفسير السورة كاملة',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(
                                        builder: (_) => SurahTafsirReaderScreen(
                                          surahNumber: ayah.surahNumber,
                                          surah: FlutterQuran().getSurah(ayah.surahNumber),
                                        )
                                      )
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded),
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  tooltip: 'نسخ الآية',
                                  onPressed: () => _copyAyah(ayah),
                                ),
                                IconButton(
                                  icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                                  color: colorScheme.primary,
                                  tooltip: 'حفظ كعلامة',
                                  onPressed: () => _toggleBookmark(ayah),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            // Determine the slide direction based on the key
                            // We use a simple fade+scale here for elegance
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.05, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<int>(_currentIndex),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Ayah Text
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 1.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    ayah.ayah.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
                                    style: TextStyle(
                                      fontSize: 24, 
                                      height: 1.8,
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.white 
                                          : const Color(0xFF1A1A1A),
                                      fontFamily: 'hafs',
                                      package: 'flutter_quran',
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                
                                // Tafsir
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                                  child: !_tafsirCache.containsKey(_currentIndex)
                                    ? const Center(child: CircularProgressIndicator())
                                    : Text(
                                        _tafsirCache[_currentIndex] ?? '',
                                        style: TextStyle(
                                          fontSize: 18, 
                                          color: colorScheme.onSurface, 
                                          height: 1.6,
                                          fontFamily: DesignTokens.fontCairo,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
