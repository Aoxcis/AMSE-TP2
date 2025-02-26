import 'package:flutter/material.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  // State variables for grid size and difficulty
  int _gridSize = 3;
  String _difficulty = 'Facile';

  final List<String> _difficulties = ['Facile', 'Moyen', 'Difficile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une partie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Grid Size Slider
            Text(
              'Grid Size: $_gridSize x $_gridSize',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Slider(
              value: _gridSize.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              onChanged: (value) {
                setState(() {
                  _gridSize = value.round();
                });
              },
            ),
            const SizedBox(height: 24),

            // Difficulty Selection
            Text(
              'Difficulty:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _difficulties.map((difficulty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: difficulty,
                        groupValue: _difficulty,
                        onChanged: (value) {
                          setState(() {
                            _difficulty = value!;
                          });
                        },
                      ),
                      Text(difficulty),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Start Button
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to game page with selected options
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Partie commencée: $_gridSize x $_gridSize, $_difficulty'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Commencer',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
