import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tp2/widgets/app_bar.dart';

class GameEndPage extends StatefulWidget {
  const GameEndPage({super.key});

  @override
  State<GameEndPage> createState() => _GameEndPageState();
}

class _GameEndPageState extends State<GameEndPage> {
  @override
  Widget build(BuildContext context) {
    // Receive the arguments passed from GamePage
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    // Extract move count and elapsed time
    final int moveCount = args['moveCount'] ?? 0;
    final Duration elapsedTime = args['elapsedTime'] ?? Duration.zero;
    final List<Uint8List> imageTiles = args['image'] ?? [];

    // Format elapsed time
    final int minutes = elapsedTime.inMinutes;
    final int seconds = elapsedTime.inSeconds % 60;

    final int gridSize = sqrt(imageTiles.length).floor();

    return Scaffold(
      appBar: MyAppBar(title: 'Fin de la partie'),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              const Text(
                'Félicitations!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous avez complété le jeu!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Display the original image (reconstructed from tiles)
              if (imageTiles.isNotEmpty)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _buildOriginalImage(imageTiles, gridSize),
                ),

              const SizedBox(height: 20),
              Text(
                'Vous avez utilisé $moveCount coups pour gagner',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Temps écoulé: $minutes minutes et $seconds secondes',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Retourner à l\'accueil'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildOriginalImage(List<Uint8List> imageTiles, int gridSize) {
  // Sort the tiles in the correct order
  final sortedTiles = List<Uint8List>.from(imageTiles);

  // Remove the last tile (empty tile) if it exists
  if (sortedTiles.length > gridSize * gridSize - 1) {
    sortedTiles.removeLast();
  }

  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: gridSize,
      crossAxisSpacing: 1,
      mainAxisSpacing: 1,
    ),
    itemCount: sortedTiles.length,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
      return Image.memory(
        sortedTiles[index],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.red.shade200,
            child: Icon(Icons.error),
          );
        },
      );
    },
  );
}
