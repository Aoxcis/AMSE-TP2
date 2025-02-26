import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tp2/pages/daily_game_page.dart';
import 'package:tp2/pages/history_page.dart';
import 'package:tp2/pages/home_page.dart';
import 'package:tp2/pages/create_game_page.dart';
import 'package:tp2/pages/info_page.dart';
import 'package:tp2/pages/settings_page.dart';
import 'package:tp2/providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Taquin',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          home: const HomePage(),
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomePage(),
            '/create': (context) => const CreateGamePage(),
            '/info': (context) => const InfoPage(),
            '/daily': (context) => const DailyGamePage(),
            '/settings': (context) => const SettingsPage(),
            '/history': (context) => const HistoryPage(),
          },
        );
      },
    );
  }
}