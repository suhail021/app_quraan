part of '../flutter_quran_screen.dart';

class AyahLongClickDialog extends StatelessWidget {
  const AyahLongClickDialog(this.ayah, {this.onTafsirTap, super.key});

  final Ayah ayah;
  final Function(Ayah)? onTafsirTap;

  @override
  Widget build(BuildContext context) {
    // Get the first bookmark (the user's main bookmark)
    final bookmarks = AppBloc.bookmarksCubit.bookmarks;
    final mainBookmark = bookmarks.isNotEmpty ? bookmarks.first : null;
    
    // Check if current ayah is bookmarked
    final isBookmarked = mainBookmark != null && mainBookmark.ayahId == ayah.id;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'خيارات الآية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo', // Assuming they use Cairo or standard font
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Tafsir Option
              if (onTafsirTap != null) ...[
                _buildOptionTile(
                  icon: Icons.menu_book_rounded,
                  title: 'عرض التفسير',
                  subtitle: 'تفسير هذه الآية',
                  color: const Color(0xFF2C3E50),
                  onTap: () {
                    Navigator.of(context).pop();
                    onTafsirTap!(ayah);
                  },
                ),
                const Divider(height: 1),
              ],

              // Bookmark Option
              if (mainBookmark != null)
                _buildOptionTile(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  title: isBookmarked ? 'إزالة العلامة' : 'حفظ كعلامة',
                  subtitle: 'الرجوع لهذه الآية لاحقاً',
                  color: const Color(0xFFD4AF37),
                  onTap: () {
                    if (isBookmarked) {
                      AppBloc.bookmarksCubit.removeBookmark(mainBookmark.id);
                    } else {
                      AppBloc.bookmarksCubit.saveBookmark(
                        ayahId: ayah.id,
                        page: ayah.page,
                        bookmarkId: mainBookmark.id,
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),

              const Divider(height: 1),

              // Copy Option
              _buildOptionTile(
                icon: Icons.copy_rounded,
                title: 'نسخ الآية',
                subtitle: 'نسخ النص للحافظة',
                color: const Color(0xFF34495E),
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: AppBloc.quranCubit.staticPages[ayah.page - 1].ayahs
                        .firstWhere((element) => element.id == ayah.id)
                        .ayah,
                  )).then((_) {
                    ToastUtils().showToast("تم النسخ بنجاح");
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: Colors.grey.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
