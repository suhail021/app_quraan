import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/services/audio_player_service.dart';
import 'reciter_surahs_bottom_sheet.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<AudioPlayerService>(context);

    final colorScheme = Theme.of(context).colorScheme;
    final cardBg = colorScheme.surface;
    final primaryAccent = colorScheme.primary;
    final textPrimary = colorScheme.onSurface;

    final bool isPlayingAny = playerService.currentSurahName.isNotEmpty;
    final String displaySurah = isPlayingAny ? playerService.currentSurahName : 'سورة الفاتحة';
    final String displayReciter = isPlayingAny ? playerService.currentReciterName : 'أحمد بن عبدالله الغباني';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ReciterSurahsBottomSheet(
            reciterName: playerService.currentReciterName.isNotEmpty ? playerService.currentReciterName : '',
          ),
        );
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
            color: colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                activeTrackColor: primaryAccent,
                inactiveTrackColor: primaryAccent.withOpacity(0.2),
                thumbColor: primaryAccent,
                overlayColor: primaryAccent.withOpacity(0.2),
                // Remove horizontal padding
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: SizedBox(
                height: 12,
                child: Slider(
                  value: playerService.duration.inMilliseconds > 0
                      ? playerService.position.inMilliseconds.toDouble()
                      : 0.0,
                  max: playerService.duration.inMilliseconds > 0
                      ? playerService.duration.inMilliseconds.toDouble()
                      : 1.0,
                  onChanged: (value) {
                    if (playerService.duration.inMilliseconds > 0) {
                      playerService.seek(Duration(milliseconds: value.toInt()));
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 16),
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => ReciterSurahsBottomSheet(
                              reciterName: playerService.currentReciterName.isNotEmpty ? playerService.currentReciterName : '',
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      displaySurah,
                                      style: TextStyle(
                                        fontFamily: DesignTokens.fontCairo,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                          onPressed: () async {
                            if (!isPlayingAny) {
                              try {
                                await playerService.playSurah(
                                  surahNumber: 1,
                                  surahName: 'الفاتحة',
                                  reciterName: 'أحمد بن عبدالله الغباني',
                                );
                              } on OfflineAudioException catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.message, style: const TextStyle(fontFamily: DesignTokens.fontCairo)),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
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
}
