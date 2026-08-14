import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/reciter_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/audio_player_service.dart';

class ReciterSurahsBottomSheet extends StatefulWidget {
  final String reciterName;
  const ReciterSurahsBottomSheet({Key? key, required this.reciterName}) : super(key: key);

  @override
  State<ReciterSurahsBottomSheet> createState() => _ReciterSurahsBottomSheetState();
}

class _ReciterSurahsBottomSheetState extends State<ReciterSurahsBottomSheet> {
  final ApiService _apiService = ApiService();
  Reciter? _reciter;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _apiService.fetchReciters();
    try {
      final reciter = list.firstWhere((r) => r.name == widget.reciterName);
      setState(() {
        _reciter = reciter;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? DesignTokens.darkCard : DesignTokens.lightCard;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.reciterName,
            style: TextStyle(
              fontFamily: DesignTokens.fontCairo,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'ابحث عن سورة...',
                hintStyle: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: primaryAccent),
                filled: true,
                fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: textPrimary.withOpacity(0.1)),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryAccent))
                : _reciter == null
                    ? Center(
                        child: Text(
                          'لم يتم العثور على القارئ',
                          style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final filteredFiles = _reciter!.audioFiles.where((file) {
                            return file.surahNameAr.contains(_searchQuery);
                          }).toList();

                          if (filteredFiles.isEmpty) {
                            return Center(
                              child: Text(
                                'لا توجد نتائج للبحث',
                                style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filteredFiles.length,
                            itemBuilder: (context, index) {
                              final file = filteredFiles[index];
                              return Consumer<AudioPlayerService>(
                                builder: (context, player, child) {
                                  final isDownloaded = player.isDownloaded(_reciter!.name, file.surahNumber);
                                  final isDownloading = player.isDownloading(_reciter!.name, file.surahNumber);

                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                                    leading: Text(
                                      file.surahNumber.toString().padLeft(3, '0'),
                                      style: TextStyle(
                                        fontFamily: DesignTokens.fontCairo,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary.withOpacity(0.4),
                                      ),
                                    ),
                                    title: Text(
                                      'سورة ${file.surahNameAr}',
                                      style: TextStyle(
                                        fontFamily: DesignTokens.fontCairo,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                    ),
                                    trailing: isDownloading
                                        ? SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
                                            ),
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              isDownloaded ? Icons.play_circle_fill_rounded : Icons.cloud_download_rounded,
                                              color: isDownloaded ? primaryAccent : goldAccent,
                                              size: 28,
                                            ),
                                            onPressed: () {
                                              player.downloadAndPlaySurah(
                                                surahNumber: file.surahNumber,
                                                surahName: file.surahNameAr,
                                                reciterName: _reciter!.name,
                                                streamUrl: file.downloadUrl,
                                              );
                                              // Optional: close bottom sheet when they play a surah
                                              Navigator.pop(context);
                                            },
                                          ),
                                  );
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
