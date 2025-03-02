import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tp2/services/game_creation_service.dart';
import 'package:tp2/services/storage.dart';

class DailyGamePage extends StatefulWidget {
  const DailyGamePage({super.key});

  @override
  State<DailyGamePage> createState() => _DailyGamePageState();
}

class _DailyGamePageState extends State<DailyGamePage> {
  DateTime _selectedDay = DateTime.now();
  final StorageService _storage = StorageService();
  final GameCreationService _gameCreationService = GameCreationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu Quotidien'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            calendarFormat: CalendarFormat.month, // Set default format to month
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            }, // Remove 2 weeks format
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _launchDailyGame(_selectedDay),
            child: const Text('Lancer le jeu quotidien'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchDailyGame(DateTime date) async {
    final gameOptions = {
      'gridSize': 3,
      'difficulty': 'Facile',
      'image': 'https://picsum.photos/300/300',
      'isDaily': true,
      'date': date.toIso8601String(),
    };

    try {
      final gameData = await _gameCreationService.createGame(gameOptions);
      final gameId = await _storage.saveGame(
        -1, // New game
        gameData['settings'],
        gameData['current'],
      );

      Navigator.pushNamed(context, '/game', arguments: {'gameId': gameId});
    } catch (e) {
      print("ERROR creating daily game: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création du jeu quotidien: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
