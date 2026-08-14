import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/services/database_helper.dart';
import '../widgets/mini_player_widget.dart';
import 'settings_screen.dart';
import 'tafsir_download_screen.dart';
import 'tafsir_surahs_screen.dart';
import '../widgets/ayah_tafsir_bottom_sheet.dart';

class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({Key? key}) : super(key: key);

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  bool _showOverlay = false;
  Timer? _hideTimer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Show overlay briefly at start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toggleOverlay();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });

    _hideTimer?.cancel();
    if (_showOverlay) {
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showOverlay = false;
          });
        }
      });
    }
  }

  void _resetTimer() {
    if (_showOverlay) {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _showOverlay = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Builder(
        builder: (innerContext) => _buildDrawer(isDark, textPrimary, innerContext),
      ),
      body: Stack(
        children: [
          // 1. Full Screen Quran
          GestureDetector(
            onTap: _toggleOverlay,
            behavior: HitTestBehavior.translucent,
            child: FlutterQuranScreen(
              showBottomWidget: true,
              useDefaultAppBar: false,
              onTafsirTap: (ayah) async {
                // 1. Highlight the ayah temporarily using the search bookmark (id: 3)
                FlutterQuran().setBookmark(ayahId: ayah.id, page: ayah.page, bookmarkId: 3);
                
                // 2. Fetch Tafsir
                final ayahsInSurah = await DatabaseHelper.instance.getAyahsBySurah(ayah.surahNumber);
                final index = ayahsInSurah.indexWhere((a) => a.numberInSurah == ayah.ayahNumber);
                final nextAyah = index >= 0 && index < ayahsInSurah.length - 1 ? ayahsInSurah[index + 1] : null;
                
                if (mounted) {
                  // 3. Show BottomSheet
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent, // Let the container handle color/shape
                    isScrollControlled: true, // Allow it to be taller if needed
                    builder: (context) {
                      return Padding(
                        // Add padding for bottom safe area and keyboard if any
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SafeArea(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.75, // Max 75% height
                            ),
                            child: AyahTafsirBottomSheet(initialAyah: ayah),
                          ),
                        ),
                      );
                    }
                  );
                  
                  // 4. Remove highlight after bottom sheet closes
                  FlutterQuran().removeBookmark(bookmarkId: 3);
                }
              },
            ),
          ),

          // 2. Animated Top Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showOverlay ? 0 : -120,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _resetTimer,
              child: _buildTopOverlay(isDark, textPrimary),
            ),
          ),

          // 3. Animated Bottom Bar with Audio Controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showOverlay ? 0 : -150,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _resetTimer,
              child: _buildBottomOverlay(isDark, textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(bool isDark, Color textPrimary) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark, color: DesignTokens.lightPrimaryAccent),
                tooltip: 'الانتقال للعلامة',
                onPressed: () {
                  final bookmarks = FlutterQuran().getAllBookmarks();
                  final mainBookmark = bookmarks.isNotEmpty ? bookmarks.first : null;
                  if (mainBookmark != null && mainBookmark.page != -1) {
                    FlutterQuran().navigateToPage(mainBookmark.page);
                  } else {
                    // Show a toast that no bookmark is saved
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا توجد علامة محفوظة حالياً')),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.menu_book, color: textPrimary),
                tooltip: 'التفسير',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TafsirSurahsScreen()));
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: textPrimary),
                tooltip: 'الإعدادات',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
            ],
          ),
          Text(
            'المصحف الشريف',
            style: TextStyle(
              fontFamily: DesignTokens.fontCairo,
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: textPrimary),
            tooltip: 'البحث عن سورة',
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(bool isDark, Color textPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Audio Player embedded in the bottom bar (Shows Reciter and Surah)
          const MiniPlayerWidget(),
        ],
      ),
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
                const Icon(Icons.menu_book, size: 50, color: Colors.white),
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
                    // Close the drawer
                    Navigator.pop(innerContext);
                    // Hide overlay
                    setState(() {
                      _showOverlay = false;
                    });
                    // Navigate to Surah
                    FlutterQuran().navigateToSurah(surahNum);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
