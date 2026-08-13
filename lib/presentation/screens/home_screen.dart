import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/surah_model.dart';
import '../../data/services/database_helper.dart';
import '../widgets/mini_player_widget.dart';
import 'book_reading_screen.dart';
import 'reciters_screen.dart';
import 'tafsir_download_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    Key? key,
    required this.onToggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final list = await DatabaseHelper.instance.getAllSurahs();
    setState(() {
      _surahs = list;
      _filteredSurahs = list;
      _isLoading = false;
    });
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredSurahs = _surahs);
    } else {
      setState(() {
        _filteredSurahs = _surahs
            .where((s) => s.nameAr.contains(query) || s.number.toString() == query)
            .toList();
      });
    }
  }

  Widget _buildSurahList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;

    return Column(
      children: [
        // حقل البحث المريح
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSurahs,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة بالاسم أو الرقم...',
              hintStyle: TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 13, color: textPrimary.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: goldAccent),
              filled: true,
              fillColor: isDark ? DesignTokens.darkCard : DesignTokens.lightCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? DesignTokens.darkBorder : DesignTokens.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? DesignTokens.darkBorder : DesignTokens.lightBorder),
              ),
            ),
          ),
        ),

        // قائمة السور
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookReadingScreen(),
                            ),
                          );
                        },
                        leading: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: goldAccent.withOpacity(0.6)),
                          ),
                          child: Text(
                            '${surah.number}',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: goldAccent,
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
                          '${surah.revelationType == "Meccan" ? "مكية" : "مدنية"} • ${surah.totalAyahs} آية',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            fontSize: 12,
                            color: textPrimary.withOpacity(0.6),
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textPrimary.withOpacity(0.4)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;

    final pages = [
      _buildSurahList(),
      const BookReadingScreen(),
      const RecitersScreen(),
      const TafsirDownloadScreen(),
      SettingsScreen(onToggleTheme: widget.onToggleTheme, isDarkMode: widget.isDarkMode),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('تطبيق سكينة — القرآن الكريم'),
            )
          : null,
      body: Column(
        children: [
          Expanded(child: pages[_currentIndex]),
          const MiniPlayerWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryAccent,
        unselectedItemColor: isDark ? DesignTokens.darkTextSecondary : DesignTokens.lightTextSecondary,
        selectedLabelStyle: const TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'المصحف'),
          BottomNavigationBarItem(icon: Icon(Icons.headphones_outlined), activeIcon: Icon(Icons.headphones), label: 'الاستماع'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_download_outlined), activeIcon: Icon(Icons.cloud_download), label: 'التفاسير'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
