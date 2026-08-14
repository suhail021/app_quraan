import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/reciter_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/audio_player_service.dart';

class RecitersScreen extends StatefulWidget {
  const RecitersScreen({Key? key}) : super(key: key);

  @override
  State<RecitersScreen> createState() => _RecitersScreenState();
}

class _RecitersScreenState extends State<RecitersScreen> {
  final ApiService _apiService = ApiService();
  List<Reciter> _reciters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReciters();
  }

  Future<void> _loadReciters() async {
    final list = await _apiService.fetchReciters();
    setState(() {
      _reciters = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('القراء والتلاوات الصوتية'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reciters.isEmpty
              ? Center(
                  child: Text(
                    'تعذر جلب القراء من الـ API.\nتأكد من تشغيل الباك إند.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = _reciters[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? DesignTokens.darkBorder : DesignTokens.lightBorder,
                        ),
                      ),
                      color: isDark ? DesignTokens.darkCard : DesignTokens.lightCard,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ExpansionTile(
                          backgroundColor: primaryAccent.withOpacity(0.02),
                          collapsedBackgroundColor: Colors.transparent,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_pin, color: primaryAccent, size: 24),
                          ),
                          title: Text(
                            reciter.name,
                            style: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textPrimary,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${reciter.totalAudioFiles} سورة (${reciter.bundledAudioFilesCount} مدمجة)',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontSize: 12,
                                color: textPrimary.withOpacity(0.6),
                              ),
                            ),
                          ),
                          children: [
                            Container(
                              color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
                              height: 1,
                            ),
                            ...reciter.audioFiles.map((file) {
                              return Consumer<AudioPlayerService>(
                                builder: (context, player, child) {
                                  final isDownloaded = player.isDownloaded(reciter.name, file.surahNumber);
                                  final isDownloading = player.isDownloading(reciter.name, file.surahNumber);

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
                                                reciterName: reciter.name,
                                                streamUrl: file.downloadUrl,
                                              );
                                            },
                                          ),
                                  );
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
