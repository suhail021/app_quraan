class ReciterAudioFile {
  final int surahNumber;
  final String surahNameAr;
  final int? fileSizeByte;
  final int? durationSeconds;
  final bool isBundled;
  final String downloadUrl;

  ReciterAudioFile({
    required this.surahNumber,
    required this.surahNameAr,
    this.fileSizeByte,
    this.durationSeconds,
    required this.isBundled,
    required this.downloadUrl,
  });

  factory ReciterAudioFile.fromJson(Map<String, dynamic> json) {
    return ReciterAudioFile(
      surahNumber: json['surah_number'] ?? 1,
      surahNameAr: json['surah_name_ar'] ?? '',
      fileSizeByte: json['file_size_bytes'],
      durationSeconds: json['duration_seconds'],
      isBundled: json['is_bundled'] ?? false,
      downloadUrl: json['download_url'] ?? '',
    );
  }
}

class Reciter {
  final int id;
  final String name;
  final String slug;
  final bool isActive;
  final int totalAudioFiles;
  final int bundledAudioFilesCount;
  final List<ReciterAudioFile> audioFiles;

  Reciter({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    required this.totalAudioFiles,
    required this.bundledAudioFilesCount,
    required this.audioFiles,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    var filesList = (json['audio_files'] as List? ?? [])
        .map((f) => ReciterAudioFile.fromJson(f))
        .toList();

    return Reciter(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      isActive: json['is_active'] ?? true,
      totalAudioFiles: json['total_audio_files'] ?? 0,
      bundledAudioFilesCount: json['bundled_audio_files_count'] ?? 0,
      audioFiles: filesList,
    );
  }
}
