import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/services/audio_player_service.dart';
import '../screens/reciters_screen.dart';
import 'full_player_widget.dart';
import 'reciter_surahs_bottom_sheet.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<AudioPlayerService>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? DesignTokens.darkCard : DesignTokens.lightCard;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;

    final bool isPlayingAny = playerService.currentSurahName.isNotEmpty;
    final String displaySurah = isPlayingAny ? playerService.currentSurahName : 'سورة الفاتحة';
    final String displayReciter = isPlayingAny ? playerService.currentReciterName : 'القارئ الإفتراضي (جاهز للتشغيل)';

    return GestureDetector(
      onTap: () {
        if (!isPlayingAny) {
          import_reciters_screen(context);
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const FullPlayerWidget(),
          );
        }
      },
      child: Container(
        height: 85,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? DesignTokens.darkBorder : DesignTokens.lightBorder,
          ),
        ),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: playerService.duration.inMilliseconds > 0
                  ? playerService.position.inMilliseconds / playerService.duration.inMilliseconds
                  : 0.0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
              minHeight: 4.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.library_music_rounded, color: primaryAccent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isPlayingAny) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ReciterSurahsBottomSheet(reciterName: playerService.currentReciterName),
                            );
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    displaySurah,
                                    style: TextStyle(
                                      fontFamily: DesignTokens.fontCairo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down, size: 16, color: primaryAccent),
                                ],
                              ),
                              Text(
                                displayReciter,
                                style: TextStyle(
                                  fontFamily: DesignTokens.fontCairo,
                                  fontSize: 12,
                                  color: textPrimary.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 28),
                          color: primaryAccent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            isPlayingAny && playerService.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            size: 44,
                            color: primaryAccent,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (!isPlayingAny) {
                              playerService.playSurah(
                                surahNumber: 1,
                                surahName: 'الفاتحة',
                                reciterName: 'أحمد الغباني',
                              );
                            } else {
                              playerService.togglePlayPause();
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 28),
                          color: primaryAccent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void import_reciters_screen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RecitersScreen()));
  }
}
