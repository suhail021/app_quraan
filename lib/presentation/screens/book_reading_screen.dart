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
  bool _showOverlay = true;
  String _drawerSearchQuery = '';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Builder(
        builder: (innerContext) =>
            _buildDrawer(innerContext),
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
                FlutterQuran().setBookmark(
                  ayahId: ayah.id,
                  page: ayah.page,
                  bookmarkId: 3,
                );

                // 2. Fetch Tafsir
                final ayahsInSurah = await DatabaseHelper.instance
                    .getAyahsBySurah(ayah.surahNumber);
                final index = ayahsInSurah.indexWhere(
                  (a) => a.numberInSurah == ayah.ayahNumber,
                );
                final nextAyah = index >= 0 && index < ayahsInSurah.length - 1
                    ? ayahsInSurah[index + 1]
                    : null;

                if (mounted) {
                  // 3. Show BottomSheet
                  await showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors
                        .transparent, // Let the container handle color/shape
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
                              maxHeight:
                                  MediaQuery.of(context).size.height *
                                  0.75, // Max 75% height
                            ),
                            child: AyahTafsirBottomSheet(initialAyah: ayah),
                          ),
                        ),
                      );
                    },
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
              child: _buildTopOverlay(colorScheme, textPrimary),
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
              child: _buildBottomOverlay(colorScheme, textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay(ColorScheme colorScheme, Color textPrimary) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
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
                icon: Icon(
                  (FlutterQuran().getAllBookmarks().isNotEmpty &&
                          FlutterQuran().getAllBookmarks().first.page != -1)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: colorScheme.primary,
                ),
                tooltip: 'الانتقال للعلامة',
                onPressed: () {
                  final bookmarks = FlutterQuran().getAllBookmarks();
                  final mainBookmark = bookmarks.isNotEmpty
                      ? bookmarks.first
                      : null;
                  if (mainBookmark != null && mainBookmark.page != -1) {
                    FlutterQuran().navigateToPage(mainBookmark.page);
                  } else {
                    // Show a toast that no bookmark is saved
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لا توجد علامة محفوظة حالياً'),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu_book),
                tooltip: 'التفسير',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TafsirSurahsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          Spacer(flex: 1),

          Text(
            'المصحف الشريف',
            style: TextStyle(
              fontFamily: DesignTokens.fontCairo,
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(flex: 1),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث عن سورة',
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(ColorScheme colorScheme, Color textPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
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

  Widget _buildDrawer(BuildContext innerContext) {
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            color: colorScheme.primary,
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _drawerSearchQuery = val.trim();
                      });
                    },
                    style: const TextStyle(fontFamily: DesignTokens.fontCairo, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة...',
                      hintStyle: TextStyle(fontFamily: DesignTokens.fontCairo, color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final filteredIndices = List.generate(114, (i) => i + 1).where((surahNum) {
                  if (_drawerSearchQuery.isEmpty) return true;
                  final surah = FlutterQuran().getSurah(surahNum);
                  return surah.nameAr.contains(_drawerSearchQuery) || surahNum.toString().contains(_drawerSearchQuery);
                }).toList();

                if (filteredIndices.isEmpty) {
                  return const Center(
                    child: Text(
                      'لم يتم العثور على سورة',
                      style: TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredIndices.length,
                  itemBuilder: (context, index) {
                    final surahNum = filteredIndices[index];
                    final surah = FlutterQuran().getSurah(surahNum);
                    final startJozz = surah.ayahs.first.jozz;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          '$surahNum',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            color: colorScheme.primary,
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
                          color: textPrimary.withValues(alpha: 0.6),
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
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
