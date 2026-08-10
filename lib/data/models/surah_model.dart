import 'ayah_model.dart';

class Surah {
  final int number;
  final String nameAr;
  final String revelationType;
  final int totalAyahs;
  final List<Ayah> ayahs;

  Surah({
    required this.number,
    required this.nameAr,
    required this.revelationType,
    required this.totalAyahs,
    this.ayahs = const [],
  });

  factory Surah.fromMap(Map<String, dynamic> map, {List<Ayah> ayahs = const []}) {
    return Surah(
      number: map['number'] ?? map['id'] ?? 1,
      nameAr: map['name_ar'] ?? map['name'] ?? '',
      revelationType: map['revelation_type'] ?? 'Meccan',
      totalAyahs: map['total_ayahs'] ?? 7,
      ayahs: ayahs,
    );
  }
}
