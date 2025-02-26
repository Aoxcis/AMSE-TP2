import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

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
      _randomImageId = Random().nextInt(10) + 1; // Random ID between 1-10
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
              onPressed: () async {
                gameOptions['gridSize'] = _gridSize;
                gameOptions['difficulty'] = _difficulty;

                if (_isRandomImage) {
                  gameOptions['image'] =
                      'https://picsum.photos/200/300?random=$_randomImageId';
                } else if (_selectedImage != null) {
                  gameOptions['image'] = _selectedImage;
                }

                final gameCreationService = GameCreationService();
                final gameData =
                    await gameCreationService.createGame(gameOptions);

                setState(() {
                  gameCurrent = gameData;
                });

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

  // Helper method to get the image decoration
  DecorationImage? _getImageProvider() {
    if (_isRandomImage) {
      // Here you would use an actual random image - this is just a placeholder
      return DecorationImage(
        image: NetworkImage(
            'https://picsum.photos/200/300?random=$_randomImageId'),
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
      return Container(); // Empty container since we're showing the image as background
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
