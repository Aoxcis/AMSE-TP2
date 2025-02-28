import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tp2/pages/game_page.dart';
import 'package:tp2/services/storage.dart';
import 'dart:io';
import 'dart:math';
import 'package:tp2/widgets/grid_overlay.dart';

import 'package:tp2/services/game_creation_service.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  // State variables for grid size and difficulty
  int _gridSize = 3;
  String _difficulty = 'Facile';
  File? _selectedImage;
  bool _isRandomImage = false;
  int _randomImageId = 1;

  final List<String> _difficulties = ['Facile', 'Moyen', 'Difficile'];
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> gameOptions = {
    'gridSize': 3,
    'difficulty': 'Facile',
    'image': null,
  };

  Map<String, dynamic> gameCurrent = {
    'currentGrid': [],
    'currentMoves': 0,
    'currentImage': null,
  };

  Future<void> _createAndStartGame() async {
    // Prepare game options
    gameOptions['gridSize'] = _gridSize;
    gameOptions['difficulty'] = _difficulty;

    // Set the appropriate image source
    if (_isRandomImage) {
      // For random images, use our random ID
      gameOptions['image'] = 'https://picsum.photos/id/$_randomImageId/300/300';
    } else if (_selectedImage != null) {
      // For gallery images, use the file
      gameOptions['image'] = _selectedImage;
    }

    try {
      // Create game using service
      final gameCreationService = GameCreationService();
      final gameData = await gameCreationService.createGame(gameOptions);

      // Debug the returned data structure
      print("DEBUG: Game created with structure: $gameData");

      // Save the game to get an ID
      final id = await gameCreationService.storageService.saveGame(
          -1, // New game
          gameData['settings'],
          gameData['current']);

      print("DEBUG: Game saved with ID: $id");

      // Navigate to game page with the ID
      Navigator.pushNamed(context, '/game', arguments: {'gameId': id});
    } catch (e) {
      print("ERROR creating game: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création du jeu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isRandomImage = false;
      });
    }
  }

  // Method to select a random image
  void _selectRandomImage() {
    setState(() {
      _selectedImage = null;
      _isRandomImage = true;
      // Picsum has images from id 1 to about 1084
      _randomImageId = Random().nextInt(1084) + 1; 
    });
  }

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
            // Image Selection Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _selectRandomImage,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Image aléatoire'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRandomImage ? Colors.deepPurple.shade200 : null,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isRandomImage && _selectedImage != null
                        ? Colors.deepPurple.shade200
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
                image: _getImageProvider(),
              ),
              child: _getImageWidget(),
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
              onPressed: _createAndStartGame,
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

  // Helper method to get the image decoration
  DecorationImage? _getImageProvider() {
    if (_isRandomImage) {
      // Here you would use an actual random image - this is just a placeholder
      return DecorationImage(
        image: NetworkImage(
            'https://picsum.photos/id/$_randomImageId/300/300'),
        fit: BoxFit.cover,
      );
    } else if (_selectedImage != null) {
      return DecorationImage(
        image: FileImage(_selectedImage!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  // Helper method to get the image widget
  Widget _getImageWidget() {
    if (_isRandomImage || _selectedImage != null) {
      return GridOverlay(
          gridSize:
              _gridSize); // Empty container since we're showing the image as background
    } else {
      return Center(
        child: Icon(
          Icons.image,
          size: 80,
          color: Colors.grey[600],
        ),
      );
    }
  }
}
