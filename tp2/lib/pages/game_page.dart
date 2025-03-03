import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:tp2/widgets/game_app_bar.dart';
import 'package:tp2/services/storage.dart';
import 'dart:convert';
import 'dart:math' show sqrt;

class GamePage extends StatefulWidget {
  final int gameId;

  const GamePage({super.key, required this.gameId});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  List<int> currentGrid = [];
  List<Uint8List> imageTiles = [];
  int gridSize = 3;
  int moveCount = 0;
  bool isCompleted = false;
  Map<String, dynamic> settings = {};
  final StorageService _storage = StorageService();

  bool _isLoading = true;
  String _errorMessage = '';
  bool _mounted = false;

  DateTime? gameStartTime;
  Duration pausedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    gameStartTime = DateTime.now();
    // Use Future.microtask to schedule this after the widget is built
    Future.microtask(() {
      if (mounted) {
        _loadGameData();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mounted = false;
    _saveTimeOnExit();
    super.dispose();
  }

  // Save time when leaving the game (if still timing)
  Future<void> _saveTimeOnExit() async {
    if (gameStartTime != null) {
      final elapsedSoFar = DateTime.now().difference(gameStartTime!);
      await _saveElapsedTime(pausedDuration + elapsedSoFar);
    } else {
      await _saveGame();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // When the app goes to background, pause the timer:
      if (gameStartTime != null) {
        pausedDuration += DateTime.now().difference(gameStartTime!);
        gameStartTime = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      // When the app is resumed, restart the timer if the game isn't completed:
      if (gameStartTime == null && !isCompleted) {
        gameStartTime = DateTime.now();
      }
    }
  }

  Map<String, dynamic> getGameInfo() {
    return {
      'nbCoups': moveCount,
    };
  }

  Future<void> _loadGameData() async {
    if (!mounted) return;

    try {
      final gameData = await _storage.loadGame(widget.gameId);

      if (gameData.isEmpty || gameData['current'] == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'La partie n\'a pas pu être chargée';
        });
        return;
      }

      final currentData = gameData['current'];

      // Handle null grid data gracefully
      List<int> gridData = [];
      if (currentData['currentGrid'] != null) {
        gridData = List<int>.from(currentData['currentGrid']);
      } else {
        print('ERROR: currentGrid is null in game data');
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Données de jeu corrompues';
        });
        return;
      }

      // Process image data with null checks
      List<Uint8List> processedImageTiles = [];
      if (currentData['currentImage'] != null) {
        final imageData = currentData['currentImage'];

        if (imageData is List) {
          for (var item in imageData) {
            if (item is String) {
              try {
                final bytes = base64Decode(item);
                processedImageTiles.add(bytes);
              } catch (e) {
                print('ERROR: Failed to decode image: $e');
              }
            }
          }
        }
      }

      // Load saved duration
      bool isNewGame = currentData['isCompleted'] != true &&
          currentData['elapsedTimeMs'] != null;

      if (isNewGame) {
        // For ongoing games, load the saved time
        pausedDuration =
            Duration(milliseconds: currentData['elapsedTimeMs'] ?? 0);
        // Start timing from now
        gameStartTime = DateTime.now();
      } else if (currentData['isCompleted'] == true) {
        // For completed games, just load the final time
        pausedDuration =
            Duration(milliseconds: currentData['elapsedTimeMs'] ?? 0);
        gameStartTime = null; // Don't continue timing
      } else {
        // Brand new game
        pausedDuration = Duration.zero;
        gameStartTime = DateTime.now();
      }

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        currentGrid = gridData;
        imageTiles = processedImageTiles;
        gridSize = sqrt(currentGrid.length).toInt();
        moveCount = currentData['currentMoves'] ?? 0;
        isCompleted = currentData['isCompleted'] ?? false;
        settings = gameData['settings'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading game: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur de chargement: $e';
      });
    }
  }

  @override
  void didChangeDependencies() {
    _mounted = true;
    super.didChangeDependencies();
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
      Navigator.pushNamed(context, '/game_end');
    }
  }

  Duration getCurrentElapsed() {
    return pausedDuration +
        (gameStartTime != null
            ? DateTime.now().difference(gameStartTime!)
            : Duration.zero);
  }

  Future<void> _saveElapsedTime(Duration elapsed) async {
    pausedDuration = elapsed;
    // Await the save operation
    await _saveGame();
  }

  // Save game state
  Future<void> _saveGame() async {
    final gameId = widget.gameId;

    Map<String, dynamic> currentState = {
      'currentGrid': currentGrid,
      'currentMoves': moveCount,
      'isCompleted': isCompleted,
      'currentImage': imageTiles,
      'elapsedTimeMs': getCurrentElapsed().inMilliseconds,
    };
    print('DEBUG: Saving game state: $currentState');

    await _storage.saveGame(gameId, settings, currentState);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: MyGameAppBar(title: 'Chargement...'),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: MyGameAppBar(title: 'Erreur'),
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

    return WillPopScope(
      onWillPop: () async {
        // Save elapsed time before popping
        if (gameStartTime != null) {
          final elapsedSoFar = DateTime.now().difference(gameStartTime!);
          await _saveElapsedTime(pausedDuration + elapsedSoFar);
        } else {
          await _saveGame();
        }
        return true; // Allow the pop to happen
      },
      child: Scaffold(
        appBar: MyGameAppBar(
          title: 'Taquin ${gridSize}x$gridSize',
          onBack: () async {
            // Save elapsed time before popping
            if (gameStartTime != null) {
              final elapsedSoFar = DateTime.now().difference(gameStartTime!);
              await _saveElapsedTime(pausedDuration + elapsedSoFar);
            } else {
              await _saveGame();
            }
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
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
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
              builder: (context, snapshot) {
                final elapsed = getCurrentElapsed();
                final formatted = elapsed.toString().split('.').first;
                return Text(
                  'Temps écoulé : $formatted',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                );
              },
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
                                                          Colors.primaries
                                                              .length],
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
                                              color: Colors.primaries[
                                                  tileValue %
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
      ),
    );
  }
}
