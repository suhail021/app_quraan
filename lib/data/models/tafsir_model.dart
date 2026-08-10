class TafsirEdition {
  final int id;
  final String key;
  final String nameAr;
  final bool isBundledDefault;
  final String version;
  final int? fileSizeBytes;
  final String downloadZipUrl;

  TafsirEdition({
    required this.id,
    required this.key,
    required this.nameAr,
    required this.isBundledDefault,
    required this.version,
    this.fileSizeBytes,
    required this.downloadZipUrl,
  });

  factory TafsirEdition.fromJson(Map<String, dynamic> json) {
    return TafsirEdition(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      nameAr: json['name_ar'] ?? '',
      isBundledDefault: json['is_bundled_default'] ?? false,
      version: json['version'] ?? '1.0',
      fileSizeBytes: json['file_size_bytes'],
      downloadZipUrl: json['download_zip_url'] ?? '',
    );
  }
}
