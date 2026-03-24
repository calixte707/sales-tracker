import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/calendar_screen.dart';

void main() {
  runApp(const SalesTrackerApp());
}

class SalesTrackerApp extends StatefulWidget {
  const SalesTrackerApp({super.key});

  @override
  State<SalesTrackerApp> createState() => _SalesTrackerAppState();
}

class _SalesTrackerAppState extends State<SalesTrackerApp> {
  String _locale = 'zh';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _initLocale();
  }

  Future<void> _initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('language_preference');
    if (saved != null && saved != 'auto') {
      setState(() { _locale = saved; _loaded = true; });
    } else {
      // Auto-detect from device
      final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      final locale = (deviceLocale == 'zh' || deviceLocale == 'zh-Hant' || deviceLocale == 'zh-Hans')
          ? 'zh'
          : 'en';
      setState(() { _locale = locale; _loaded = true; });
    }
  }

  void _toggleLocale() async {
    final next = _locale == 'zh' ? 'en' : 'zh';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_preference', next);
    setState(() => _locale = next);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFFFAF7F4),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF8B6F5E)),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sales Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6F5E),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFFAF7F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF7F4),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B6F5E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      home: CalendarScreen(
        locale: _locale,
        onToggleLocale: _toggleLocale,
      ),
    );
  }
}
