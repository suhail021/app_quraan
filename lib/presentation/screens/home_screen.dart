import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/surah_model.dart';
import '../../data/services/database_helper.dart';
import '../widgets/mini_player_widget.dart';
import 'book_reading_screen.dart';
import 'tafsir_download_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final primaryAccent = colorScheme.primary;

    return Column(
      children: [
        // واجهة علوية مخصصة (Custom Header)
        Container(
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
          decoration: BoxDecoration(
            color: primaryAccent,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: الترحيب وزر الإعدادات على اليسار
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'السلام عليكم',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: DesignTokens.fontCairo,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'تطبيق سكينة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: DesignTokens.fontCairo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // بطاقة آخر قراءة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.menu_book_rounded, color: primaryAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'آخر قراءة',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              fontSize: 12,
                              color: textPrimary.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'سورة البقرة - آية ١',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.play_circle_fill, color: primaryAccent, size: 36),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookReadingScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // حقل البحث المريح
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: TextField(
            controller: _searchController,
            onChanged: _filterSurahs,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة بالاسم أو الرقم...',
              hintStyle: TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 13, color: textPrimary.withOpacity(0.5)),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, color: primaryAccent),
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: primaryAccent.withValues(alpha: 0.5)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
            ),
          ),
        ),

        // قائمة السور
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surah = _filteredSurahs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: colorScheme.surface.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                      ),
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
                            border: Border.all(color: primaryAccent.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            '${surah.number}',
                            style: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              fontSize: 12,
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
                          '${surah.revelationType == "Meccan" ? "مكية" : "مدنية"} • ${surah.totalAyahs} آية',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            fontSize: 12,
                            color: textPrimary.withOpacity(0.6),
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primaryAccent.withValues(alpha: 0.3)),
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
    final colorScheme = Theme.of(context).colorScheme;
    final primaryAccent = colorScheme.primary;

    final pages = [
      _buildSurahList(),
      const BookReadingScreen(),
      const TafsirDownloadScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // لا حاجة لـ AppBar هنا بعد الآن لأننا بنيناه بداخل الشاشة
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
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'المصحف'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_download_outlined), activeIcon: Icon(Icons.cloud_download), label: 'التفاسير'),
        ],
      ),
    );
  }
}
