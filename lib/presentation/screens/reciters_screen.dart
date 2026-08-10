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
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryAccent.withOpacity(0.1),
                          child: Icon(Icons.mic, color: primaryAccent),
                        ),
                        title: Text(
                          reciter.name,
                          style: TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${reciter.totalAudioFiles} سورة متوفرة (${reciter.bundledAudioFilesCount} مدمجة أوفلاين)',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            fontSize: 12,
                            color: textPrimary.withOpacity(0.6),
                          ),
                        ),
                        children: reciter.audioFiles.map((file) {
                          return ListTile(
                            dense: true,
                            title: Text(
                              'سورة ${file.surahNameAr}',
                              style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary),
                            ),
                            subtitle: Text(
                              file.isBundled ? 'مدمجة بالتطبيق أوفلاين' : 'تحميل عند الطلب',
                              style: TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontSize: 11,
                                color: file.isBundled ? const Color(0xFF10B981) : goldAccent,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.play_arrow_rounded, color: primaryAccent),
                              onPressed: () {
                                final player = Provider.of<AudioPlayerService>(context, listen: false);
                                player.playSurah(
                                  surahNumber: file.surahNumber,
                                  surahName: file.surahNameAr,
                                  reciterName: reciter.name,
                                  streamUrl: file.downloadUrl,
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
}
