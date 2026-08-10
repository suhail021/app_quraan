import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/services/audio_player_service.dart';
import 'presentation/screens/book_reading_screen.dart';

import 'package:flutter_quran/flutter_quran.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterQuran().init();
  runApp(const QuranApp());
}

class QuranApp extends StatefulWidget {
  const QuranApp({Key? key}) : super(key: key);

  @override
  State<QuranApp> createState() => _QuranAppState();
}

class _QuranAppState extends State<QuranApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
      ],
      child: MaterialApp(
        title: 'سكينة — القرآن الكريم',
        debugShowCheckedModeBanner: false,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        // إعدادات اللغة العربية والاتجاه من اليمين لليسار RTL
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'),
        ],
        locale: const Locale('ar', 'SA'),

        home: const BookReadingScreen(),
      ),
    );
  }
}
