import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/services/audio_player_service.dart';

class FullPlayerWidget extends StatelessWidget {
  const FullPlayerWidget({Key? key}) : super(key: key);

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playerService = Provider.of<AudioPlayerService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? DesignTokens.darkCard : DesignTokens.lightCard;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // مقبض السحب للأعلى/الأسفل
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // اسم السورة والقارئ
          Text(
            playerService.currentSurahName,
            style: TextStyle(
              fontFamily: DesignTokens.fontCairo,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            playerService.currentReciterName,
            style: TextStyle(
              fontFamily: DesignTokens.fontCairo,
              fontSize: 14,
              color: textPrimary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),

          // مؤشر حالة التخزين (أوفلاين / أونلاين)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: playerService.isOffline ? const Color(0xFF10B981).withOpacity(0.15) : primaryAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  playerService.isOffline ? Icons.offline_pin : Icons.cloud_done,
                  size: 14,
                  color: playerService.isOffline ? const Color(0xFF10B981) : primaryAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  playerService.isOffline ? 'ملف مدمج / أوفلاين' : 'بث مباشر عبر الإنترنت',
                  style: TextStyle(
                    fontFamily: DesignTokens.fontCairo,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: playerService.isOffline ? const Color(0xFF10B981) : primaryAccent,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // العنصر البصري المركزي (زخرفة دائرية ذهبية متحركة هادئة)
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldAccent.withOpacity(0.4), width: 2),
              gradient: RadialGradient(
                colors: [
                  goldAccent.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.star_outline_rounded,
                size: 80,
                color: goldAccent,
              ),
            ),
          ),

          const Spacer(),

          // شريط التقدم والوقت
          Slider(
            value: playerService.duration.inMilliseconds > 0
                ? playerService.position.inMilliseconds.clamp(0, playerService.duration.inMilliseconds).toDouble()
                : 0.0,
            max: playerService.duration.inMilliseconds > 0
                ? playerService.duration.inMilliseconds.toDouble()
                : 1.0,
            activeColor: goldAccent,
            inactiveColor: goldAccent.withOpacity(0.2),
            onChanged: (val) {
              playerService.seek(Duration(milliseconds: val.toInt()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(playerService.position),
                  style: TextStyle(
                    fontFamily: DesignTokens.fontCairo,
                    fontSize: 12,
                    color: textPrimary.withOpacity(0.6),
                  ),
                ),
                Text(
                  _formatDuration(playerService.duration),
                  style: TextStyle(
                    fontFamily: DesignTokens.fontCairo,
                    fontSize: 12,
                    color: textPrimary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // أزرار التشغيل والتحكم الرئيسي
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 36),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  playerService.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  size: 64,
                  color: primaryAccent,
                ),
                onPressed: () => playerService.togglePlayPause(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 36),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
