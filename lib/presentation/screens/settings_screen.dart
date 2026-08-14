import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/design_tokens.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onToggleTheme;
  final bool? isDarkMode;

  const SettingsScreen({
    Key? key,
    this.onToggleTheme,
    this.isDarkMode,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTafsir = 'muyassar';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? DesignTokens.darkTextPrimary : DesignTokens.lightTextPrimary;
    final primaryAccent = isDark ? DesignTokens.darkPrimaryAccent : DesignTokens.lightPrimaryAccent;
    final goldAccent = isDark ? DesignTokens.darkGoldAccent : DesignTokens.lightGoldAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والتخصيص'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // المظهر والوضع الليلي
          if (widget.onToggleTheme != null && widget.isDarkMode != null)
            Card(
              child: SwitchListTile(
                secondary: Icon(widget.isDarkMode! ? Icons.dark_mode : Icons.light_mode, color: goldAccent),
                title: Text(
                  'الوضع الليلي (Dark Mode)',
                  style: TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                subtitle: Text(
                  'تبديل ألوان الواجهة إلى الكحلي البنفسجي المريح للعين',
                  style: TextStyle(fontFamily: DesignTokens.fontCairo, fontSize: 12, color: textPrimary.withOpacity(0.6)),
                ),
                value: widget.isDarkMode!,
                onChanged: (val) => widget.onToggleTheme!(val),
              ),
            ),
          const SizedBox(height: 12),

          // اختيار التفسير الافتراضي
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: primaryAccent),
                      const SizedBox(width: 12),
                      Text(
                        'التفسير الافتراضي عند القراءة',
                        style: TextStyle(fontFamily: DesignTokens.fontCairo, fontWeight: FontWeight.bold, color: textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedTafsir,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'muyassar', child: Text('التفسير الميسر (مدمج دائماً)')),
                      DropdownMenuItem(value: 'saadi', child: Text('تفسير السعدي')),
                      DropdownMenuItem(value: 'ibn_kathir', child: Text('تفسير ابن كثير')),
                      DropdownMenuItem(value: 'mukhtasar', child: Text('المختصر في التفسير')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedTafsir = val);
                      }
                    },
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
