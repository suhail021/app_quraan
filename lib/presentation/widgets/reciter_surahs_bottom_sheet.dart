import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_quran/flutter_quran.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/reciter_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/audio_player_service.dart';

class ReciterSurahsBottomSheet extends StatefulWidget {
  final String reciterName;
  const ReciterSurahsBottomSheet({Key? key, required this.reciterName})
    : super(key: key);

  @override
  State<ReciterSurahsBottomSheet> createState() =>
      _ReciterSurahsBottomSheetState();
}

class _ReciterSurahsBottomSheetState extends State<ReciterSurahsBottomSheet>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Reciter? _reciter;
  List<Reciter> _allReciters = [];
  String _searchQuery = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _reciter = _getDefaultMockReciter();
    _allReciters = [_reciter!];

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _loadData(); // يعمل في الخلفية بصمت
  }

  Reciter _getDefaultMockReciter() {
    final defaultName = widget.reciterName.isNotEmpty ? widget.reciterName : 'أحمد بن عبدالله الغباني';
    final surahs = <ReciterAudioFile>[];
    for (int i = 1; i <= 114; i++) {
      final s = FlutterQuran().getSurah(i);
      surahs.add(ReciterAudioFile(
        surahNumber: i,
        surahNameAr: s.nameAr,
        isBundled: false, // We just assume false for the mock until API loads
        downloadUrl: '',
      ));
    }
    return Reciter(
      id: 1,
      name: defaultName,
      slug: 'ahmed-alghabani',
      isActive: true,
      totalAudioFiles: 114,
      bundledAudioFilesCount: 39,
      audioFiles: surahs,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final list = await _apiService.fetchReciters();
    if (list.isEmpty) return; // الاحتفاظ بالمحلي لو فشل كل شيء
    try {
      final reciter = list.firstWhere(
        (r) =>
            r.name.contains(widget.reciterName) ||
            widget.reciterName.contains(r.name),
        orElse: () => list.first,
      );
      if (mounted) {
        setState(() {
          _allReciters = list;
          _reciter = reciter;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allReciters = list;
          if (list.isNotEmpty) _reciter = list.first;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF7F7F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final textSecondary = isDark ? Colors.white70 : const Color(0xFF6B7280);
    final primaryAccent = isDark
        ? DesignTokens.darkPrimaryAccent
        : DesignTokens.lightPrimaryAccent;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              gradient: LinearGradient(
                colors: [
                  primaryAccent.withOpacity(0.9),
                  primaryAccent.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  
                  children: [
                    const SizedBox(width: 20),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _allReciters.isEmpty
                          ? Text(
                              _reciter?.name ?? widget.reciterName,
                              style: const TextStyle(
                                fontFamily: DesignTokens.fontCairo,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<Reciter>(
                                value: _reciter,
                                icon: const SizedBox.shrink(),
                                iconSize: 0.0,
                                dropdownColor: primaryAccent.withOpacity(0.95),
                                isExpanded: true,
                                style: const TextStyle(
                                  fontFamily: DesignTokens.fontCairo,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                selectedItemBuilder: (BuildContext context) {
                                  return _allReciters.map<Widget>((Reciter item) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontFamily: DesignTokens.fontCairo,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 32),
                                      ],
                                    );
                                  }).toList();
                                },
                                onChanged: (Reciter? newReciter) {
                                  if (newReciter != null && newReciter.id != _reciter?.id) {
                                    setState(() {
                                      _reciter = newReciter;
                                    });
                                  }
                                },
                                items: _allReciters.map<DropdownMenuItem<Reciter>>((Reciter r) {
                                  return DropdownMenuItem<Reciter>(
                                    value: r,
                                    child: Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontFamily: DesignTokens.fontCairo,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                 
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          style: const TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن سورة...',
                            hintStyle: TextStyle(
                              fontFamily: DesignTokens.fontCairo,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
            ),
          ),

          // List Section
          Expanded(
            child: _reciter == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لم يتم العثور على بيانات القارئ',
                          style: TextStyle(
                            fontFamily: DesignTokens.fontCairo,
                            color: textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Builder(
                    builder: (context) {
                      final filteredFiles = _reciter!.audioFiles.where((file) {
                        return file.surahNameAr.contains(_searchQuery);
                      }).toList();

                      if (filteredFiles.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد سورة بهذا الاسم',
                                style: TextStyle(
                                  fontFamily: DesignTokens.fontCairo,
                                  color: textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: filteredFiles.length,
                        itemBuilder: (context, index) {
                          final file = filteredFiles[index];
                          return Consumer<AudioPlayerService>(
                            builder: (context, player, child) {
                              final isDownloaded =
                                  player.isDownloaded(
                                    _reciter!.name,
                                    file.surahNumber,
                                  ) ||
                                  file.isBundled;
                              final isDownloading = player.isDownloading(
                                _reciter!.name,
                                file.surahNumber,
                              );
                              final isPlaying =
                                  player.currentSurahName ==
                                      'سورة ${file.surahNameAr}' &&
                                  player.currentReciterName == _reciter!.name;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF252538)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isPlaying
                                        ? primaryAccent.withOpacity(0.5)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.2 : 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? primaryAccent
                                          : primaryAccent.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      file.surahNumber.toString(),
                                      style: TextStyle(
                                        fontFamily: DesignTokens.fontCairo,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isPlaying
                                            ? Colors.white
                                            : primaryAccent,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    'سورة ${file.surahNameAr}',
                                    style: TextStyle(
                                      fontFamily: DesignTokens.fontCairo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    file.isBundled
                                        ? 'مدمجة في التطبيق'
                                        : 'تتطلب تحميل',
                                    style: TextStyle(
                                      fontFamily: DesignTokens.fontCairo,
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                  trailing: isDownloading
                                      ? SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  primaryAccent,
                                                ),
                                          ),
                                        )
                                      : AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: isPlaying
                                                  ? 1.0 +
                                                        (_pulseController
                                                                .value *
                                                            0.1)
                                                  : 1.0,
                                              child: IconButton(
                                                icon: Icon(
                                                  (isPlaying && player.isPlaying)
                                                      ? Icons
                                                            .pause_circle_filled_rounded
                                                      : isDownloaded
                                                      ? Icons
                                                            .play_circle_fill_rounded
                                                      : Icons
                                                            .cloud_download_rounded,
                                                  color:
                                                      isPlaying || isDownloaded
                                                      ? primaryAccent
                                                      : textSecondary
                                                            .withOpacity(0.6),
                                                  size: 36,
                                                ),
                                                onPressed: () async {
                                                  if (isPlaying &&
                                                      player.isPlaying) {
                                                    player.pause();
                                                  } else if (isPlaying &&
                                                      !player.isPlaying) {
                                                    player.resume();
                                                  } else {
                                                    try {
                                                      await player.downloadAndPlaySurah(
                                                        surahNumber:
                                                            file.surahNumber,
                                                        surahName:
                                                            file.surahNameAr,
                                                        reciterName:
                                                            _reciter!.name,
                                                        streamUrl:
                                                            file.downloadUrl,
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
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
