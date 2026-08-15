import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textPrimary = colorScheme.onSurface;
    final primaryAccent = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والتخصيص'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // المظهر والوضع الليلي
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Card(
                child: SwitchListTile(
                  secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: primaryAccent),
                  title: Text(
                    'الوضع الليلي والنهاري',
                    style: TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  subtitle: Text(
                    'تبديل ألوان الواجهة بين الوضع النهاري الفاتح والوضع الليلي المريح للعين',
                    style: TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 12, color: textPrimary.withOpacity(0.6)),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // عن التطبيق
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: DesignTokens.lightPrimaryAccent),
                      const SizedBox(width: 12),
                      Text(
                        'عن التطبيق',
                        style: TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, color: textPrimary, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 64, color: DesignTokens.lightPrimaryAccent),
                        const SizedBox(height: 8),
                        Text(
                          'تطبيق القرآن الكريم',
                          style: TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, color: textPrimary, fontSize: 18),
                        ),
                        Text(
                          'الإصدار 1.0.0',
                          style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary.withOpacity(0.6), fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'تطبيق شامل لقراءة القرآن الكريم والاستماع للتلاوات وتصفح التفاسير المختلفة بسهولة ويسر.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: DesignTokens.fontCairo, color: textPrimary, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'نسأل الله أن يتقبل هذا العمل خالصاً لوجهه الكريم.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: DesignTokens.fontCairo, color: primaryAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
