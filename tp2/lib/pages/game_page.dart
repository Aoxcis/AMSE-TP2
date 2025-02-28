import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/services/storage.dart';
import 'dart:convert';
import 'dart:math' show sqrt;

class GamePage extends StatefulWidget {
  final int gameId;

  const GamePage({super.key, required this.gameId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<int> currentGrid = [];
  List<Uint8List> imageTiles = [];
  int gridSize = 3;
  int moveCount = 0;
  bool isCompleted = false;
  Map<String, dynamic> settings = {};
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      final gameData = await _storage.loadGame(widget.gameId);
      print('DEBUG: Loaded game data: $gameData');

      if (gameData.isEmpty || gameData['current'] == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'La partie n\'a pas pu être chargée';
        });
        return;
      }

      final currentData = gameData['current'];
      final gridData = List<int>.from(currentData['currentGrid']);

      // Process image data - might be stored as a list of base64 strings
      List<Uint8List> processedImageTiles = [];

      if (currentData['currentImage'] != null) {
        final imageData = currentData['currentImage'];

        // Extra debugging
        print('DEBUG: Image data runtimeType: ${imageData.runtimeType}');

        if (imageData is List) {
          print('DEBUG: Processing ${imageData.length} images');

          for (int i = 0; i < imageData.length; i++) {
            if (imageData[i] is String) {
              try {
                // Decode base64 string to Uint8List
                String base64String = imageData[i];
                print(
                    'DEBUG: Base64 length for tile $i: ${base64String.length}');

                // Check if base64 string looks valid
                if (base64String.length < 10) {
                  print('WARNING: Base64 string too short for tile $i');
                  continue;
                }

                final bytes = base64Decode(base64String);
                print(
                    'DEBUG: Successfully decoded image $i: ${bytes.length} bytes');
                processedImageTiles.add(bytes);
              } catch (e) {
                print('ERROR: Failed to decode image $i: $e');
              }
            } else {
              print(
                  'WARNING: Image data $i is not a String: ${imageData[i].runtimeType}');
            }
          }
        }
      }

      setState(() {
        currentGrid = gridData;
        imageTiles = processedImageTiles;
        gridSize = sqrt(currentGrid.length).toInt(); // More accurate
        moveCount = currentData['currentMoves'] ?? 0;
        isCompleted = currentData['isCompleted'] ?? false;
        settings = gameData['settings'] ?? {};
        _isLoading = false;
      });

      print(
          'Game loaded with ${imageTiles.length} image tiles, isEmpty=${imageTiles.isEmpty}');
    } catch (e) {
      print('Error loading game: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de chargement: $e';
      });
    }
  }

  // Check if a move is valid based on empty space position
  bool _isValidMove(int tileIndex) {
    // Find the empty tile (which should be gridSize*gridSize-1)
    int emptyIndex = currentGrid.indexOf(gridSize * gridSize - 1);

    // Calculate grid positions
    int tileRow = tileIndex ~/ gridSize;
    int tileCol = tileIndex % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    // Valid move if tile is adjacent to empty space
    return (tileRow == emptyRow &&
            (tileCol == emptyCol - 1 || tileCol == emptyCol + 1)) ||
        (tileCol == emptyCol &&
            (tileRow == emptyRow - 1 || tileRow == emptyRow + 1));
  }

  // Make a move by swapping a tile with the empty space
  void _makeMove(int tileIndex) {
    if (!_isValidMove(tileIndex)) return;

    setState(() {
      // Find the empty tile
      int emptyIndex = currentGrid.indexOf(gridSize * gridSize - 1);

      // Swap the tile with empty space
      int temp = currentGrid[tileIndex];
      currentGrid[tileIndex] = currentGrid[emptyIndex];
      currentGrid[emptyIndex] = temp;

      moveCount++;

      // Check if puzzle is solved
      _checkCompletion();
    });

    // Save game state
    _saveGame();
  }

  // Check if the puzzle is completed
  void _checkCompletion() {
    bool solved = true;

    // Puzzle is solved if all tiles are in order (0,1,2,...,n-1)
    for (int i = 0; i < currentGrid.length - 1; i++) {
      if (currentGrid[i] != i) {
        solved = false;
        break;
      }
    }

    if (solved) {
      setState(() {
        isCompleted = true;
      });

      // Show completion dialog
      _showCompletionDialog();
    }
  }

  // Save game state
  Future<void> _saveGame() async {
    final gameId = widget.gameId;

    // Don't try to save the image data each time - too large and unnecessary
    // Once loaded, we can keep using the same image tiles
    Map<String, dynamic> currentState = {
      'currentGrid': currentGrid,
      'currentMoves': moveCount,
      'isCompleted': isCompleted,
      // Only send image data on first save or if we have to
      'currentImage': imageTiles,
    };

    await _storage.saveGame(gameId, settings, currentState);
  }

  // Show completion dialog
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations!'),
        content: Text('Vous avez résolu le puzzle en $moveCount coups.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/game_end');
            },
            child: const Text('fenetre de fin de jeu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: MyAppBar(title: 'Chargement...'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: MyAppBar(title: 'Erreur'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MyAppBar(title: 'Taquin ${gridSize}x$gridSize'),
      body: Column(
        children: [
          // Game stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Mouvements: $moveCount',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Difficulté: ${settings["difficulty"] ?? "Normal"}',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          // Game board
          imageTiles.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      "Aucune image disponible. Veuillez créer une nouvelle partie.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                          ),
                          itemCount: gridSize * gridSize,
                          physics: const NeverScrollableScrollPhysics(),
                          // Inside GridView.builder's itemBuilder function:
                          itemBuilder: (context, index) {
                            final tileValue = currentGrid[index];
                            final isEmptyTile =
                                tileValue == gridSize * gridSize - 1;

                            return GestureDetector(
                              onTap: () {
                                if (!isCompleted) {
                                  _makeMove(index);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isEmptyTile
                                      ? Colors.transparent
                                      : Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: isEmptyTile
                                    ? const SizedBox() // Empty tile
                                    : imageTiles.isNotEmpty &&
                                            tileValue < imageTiles.length
                                        ? Image.memory(
                                            imageTiles[tileValue],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Error loading image: $error');
                                              // Fallback to colored tile with number
                                              return Container(
                                                color: Colors.primaries[
                                                    tileValue %
                                                        Colors
                                                            .primaries.length],
                                                child: Center(
                                                  child: Text(
                                                    '${tileValue + 1}',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.primaries[tileValue %
                                                Colors.primaries.length],
                                            child: Center(
                                              child: Text(
                                                '${tileValue + 1}',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
