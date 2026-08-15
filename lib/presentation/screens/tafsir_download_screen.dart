import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';
import '../../data/models/tafsir_model.dart';
import '../../data/services/api_service.dart';

class TafsirDownloadScreen extends StatefulWidget {
  const TafsirDownloadScreen({Key? key}) : super(key: key);

  @override
  State<TafsirDownloadScreen> createState() => _TafsirDownloadScreenState();
}

class _TafsirDownloadScreenState extends State<TafsirDownloadScreen> {
  final ApiService _apiService = ApiService();
  List<TafsirEdition> _tafsirs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTafsirs();
  }

  Future<void> _loadTafsirs() async {
    final list = await _apiService.fetchTafsirs();
    setState(() {
      _tafsirs = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final primaryAccent = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحميل التفاسير الإضافية'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tafsirs.length,
              itemBuilder: (context, index) {
                final tafsir = _tafsirs[index];
                final sizeMb = tafsir.fileSizeBytes != null
                    ? (tafsir.fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)
                    : '4.8';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.download_for_offline, color: primaryAccent, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tafsir.nameAr,
                                style: TextStyle(
                                  fontFamily: DesignTokens.fontCairo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tafsir.isBundledDefault
                                    ? 'متوفر دائماً — مدمج بالتطبيق أوفلاين'
                                    : 'الحجم التقريبي: ~$sizeMb MB',
                                style: TextStyle(
                                  fontFamily: DesignTokens.fontCairo,
                                  fontSize: 12,
                                  color: tafsir.isBundledDefault ? const Color(0xFF10B981) : textPrimary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (tafsir.isBundledDefault)
                          const Icon(Icons.check_circle, color: Color(0xFF10B981))
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryAccent,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('تحميل ZIP', style: TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 12)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('جاري بدء تحميل حزمة ${tafsir.nameAr}...'),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
