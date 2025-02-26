import 'package:flutter/material.dart';
import 'package:tp2/pages/daily_game_page.dart';
import 'package:tp2/pages/history_page.dart';

import 'package:tp2/pages/home_page.dart';
import 'package:tp2/pages/create_game_page.dart';
import 'package:tp2/pages/info_page.dart';
import 'package:tp2/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taquin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/create': (context) => const CreateGamePage(),
        '/info': (context) => const InfoPage(),
        '/daily': (context) => const DailyGamePage(),
        '/settings': (context) => const SettingsPage(),
        '/history': (context) => const HistoryPage(),
        //TODO: Add routes for the other pages
      },
    );
  }
}
