import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quran/flutter_quran.dart';
import '../../data/services/database_helper.dart';

class AyahTafsirBottomSheet extends StatefulWidget {
  final Ayah initialAyah;

  const AyahTafsirBottomSheet({Key? key, required this.initialAyah}) : super(key: key);

  @override
  State<AyahTafsirBottomSheet> createState() => _AyahTafsirBottomSheetState();
}

class _AyahTafsirBottomSheetState extends State<AyahTafsirBottomSheet> {
  late Ayah _currentAyah;
  String? _tafsirText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentAyah = widget.initialAyah;
    _fetchTafsir();
    _updateHighlight();
  }

  @override
  void dispose() {
    // Remove highlight when closing
    FlutterQuran().removeBookmark(bookmarkId: 3);
    super.dispose();
  }

  void _updateHighlight() {
    // Remove old and set new temporary highlight (id 3)
    FlutterQuran().removeBookmark(bookmarkId: 3);
    FlutterQuran().setBookmark(
        ayahId: _currentAyah.id, page: _currentAyah.page, bookmarkId: 3);
    
    // Auto navigate to the page if it's off-screen
    if (FlutterQuran().getCurrentPageNumber() != _currentAyah.page) {
      FlutterQuran().navigateToPage(_currentAyah.page);
    }
  }

  Future<void> _fetchTafsir() async {
    setState(() => _isLoading = true);
    
    final ayahsInSurah = await DatabaseHelper.instance.getAyahsBySurah(_currentAyah.surahNumber);
    final ayahModel = ayahsInSurah.firstWhere(
      (a) => a.numberInSurah == _currentAyah.ayahNumber, 
      orElse: () => ayahsInSurah.first
    );
    
    if (mounted) {
      setState(() {
        _tafsirText = ayahModel.tafsirMuyassar ?? 'لا يتوفر تفسير لهذه الآية حالياً.';
        _isLoading = false;
      });
    }
  }

  void _nextAyah() {
    final nextAyah = FlutterQuran().getAyahByNumber(_currentAyah.surahNumber, _currentAyah.ayahNumber + 1) ??
                     FlutterQuran().getAyahByNumber(_currentAyah.surahNumber + 1, 1);
    
    if (nextAyah != null) {
      setState(() {
        _currentAyah = nextAyah!;
      });
      _updateHighlight();
      _fetchTafsir();
    }
  }

  void _prevAyah() {
    Ayah? prevAyah;
    if (_currentAyah.ayahNumber > 1) {
      prevAyah = FlutterQuran().getAyahByNumber(_currentAyah.surahNumber, _currentAyah.ayahNumber - 1);
    } else if (_currentAyah.surahNumber > 1) {
      final prevSurah = FlutterQuran().getSurah(_currentAyah.surahNumber - 1);
      prevAyah = FlutterQuran().getAyahByNumber(_currentAyah.surahNumber - 1, prevSurah.ayahs.length);
    }
    
    if (prevAyah != null) {
      setState(() {
        _currentAyah = prevAyah!;
      });
      _updateHighlight();
      _fetchTafsir();
    }
  }

  void _toggleBookmark() {
    final bookmarks = FlutterQuran().getAllBookmarks();
    final mainBookmark = bookmarks.isNotEmpty ? bookmarks.first : null;
    
    if (mainBookmark != null) {
      if (mainBookmark.ayahId == _currentAyah.id) {
        FlutterQuran().removeBookmark(bookmarkId: mainBookmark.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إزالة العلامة المرجعية')));
      } else {
        FlutterQuran().setBookmark(
          ayahId: _currentAyah.id, 
          page: _currentAyah.page, 
          bookmarkId: mainBookmark.id
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ العلامة المرجعية بنجاح')));
      }
      setState(() {}); // Rebuild to update bookmark icon
    }
  }

  void _copyAyah() {
    Clipboard.setData(ClipboardData(text: '﴿${_currentAyah.ayah}﴾')).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الآية للحافظة')));
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainBookmark = FlutterQuran().getAllBookmarks().isNotEmpty 
        ? FlutterQuran().getAllBookmarks().first 
        : null;
    final isBookmarked = mainBookmark != null && mainBookmark.ayahId == _currentAyah.id;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header: Title and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'تفسير الآية ${_currentAyah.ayahNumber} - سورة ${_currentAyah.surahNameAr}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18, 
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      color: Colors.grey.shade600,
                      tooltip: 'نسخ الآية',
                      onPressed: _copyAyah,
                    ),
                    IconButton(
                      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                      color: const Color(0xFFD4AF37),
                      tooltip: 'حفظ كعلامة',
                      onPressed: _toggleBookmark,
                    ),
                  ],
                ),
              ],
            ),
            
            // Ayah Text
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6EE), // Very light gold/cream
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${_currentAyah.ayah.trim()} ﴿${_currentAyah.ayahNumber}﴾',
                style: const TextStyle(
                  fontSize: 16, 
                  height: 1.5,
                  color: Color(0xFF1A1A1A), 
                  fontFamily: 'hafs',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Tafsir
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        _tafsirText ?? '',
                        style: const TextStyle(
                          fontSize: 18, 
                          color: Colors.black87, 
                          height: 1.5,
                        ),
                      ),
                ),
              ),
            ),
            
            // Navigation Bottom Bar
            Container(
              padding: const EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                    label: const Text('الآية السابقة'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2C3E50),
                    ),
                    onPressed: _prevAyah,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: const Text('الآية التالية'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2C3E50),
                    ),
                    // Swap icon and label positions for RTL
                    iconAlignment: IconAlignment.end,
                    onPressed: _nextAyah,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
