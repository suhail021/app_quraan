class Ayah {
  final int numberInSurah;
  final int surahNumber;
  final String textUthmanic;
  final String? tafsirMuyassar;
  final int pageNumber;
  final int juzNumber;

  Ayah({
    required this.numberInSurah,
    required this.surahNumber,
    required this.textUthmanic,
    this.tafsirMuyassar,
    required this.pageNumber,
    required this.juzNumber,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      numberInSurah: map['number_in_surah'] ?? map['ayah_number'] ?? 1,
      surahNumber: map['surah_number'] ?? 1,
      textUthmanic: map['text_uthmanic'] ?? '',
      tafsirMuyassar: map['tafsir_muyassar'],
      pageNumber: map['page_number'] ?? 1,
      juzNumber: map['juz_number'] ?? 1,
    );
  }
}
