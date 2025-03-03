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

  // Using Stopwatch to manage elapsed time
  final Stopwatch _stopwatch = Stopwatch();
  // _baseElapsed stores the accumulated time during pauses
  Duration _baseElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start the stopwatch for a new game
    _stopwatch.start();
    // Load game data after the widget is built
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

  Future<void> _saveTimeOnExit() async {
    // Stop the stopwatch and add its elapsed time to _baseElapsed if running
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _baseElapsed += _stopwatch.elapsed;
      _stopwatch.reset();
    }
    await _saveGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _baseElapsed += _stopwatch.elapsed;
        _stopwatch.reset();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!isCompleted && !_stopwatch.isRunning) {
        _stopwatch.start();
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

      // Load grid data
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

      // Process image data
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

      // Load saved elapsed time
      bool isNewGame = currentData['isCompleted'] != true &&
          currentData['elapsedTimeMs'] != null;
      int savedElapsedMs = currentData['elapsedTimeMs'] ?? 0;

      if (isNewGame) {
        _baseElapsed = Duration(milliseconds: savedElapsedMs);
        _stopwatch.reset();
        _stopwatch.start();
      } else if (currentData['isCompleted'] == true) {
        _baseElapsed = Duration(milliseconds: savedElapsedMs);
        _stopwatch.reset();
      } else {
        _baseElapsed = Duration.zero;
        _stopwatch.reset();
        _stopwatch.start();
      }

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

  bool _isValidMove(int tileIndex) {
    int emptyIndex = currentGrid.indexOf(gridSize * gridSize - 1);
    int tileRow = tileIndex ~/ gridSize;
    int tileCol = tileIndex % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;
    return (tileRow == emptyRow &&
            (tileCol == emptyCol - 1 || tileCol == emptyCol + 1)) ||
        (tileCol == emptyCol &&
            (tileRow == emptyRow - 1 || tileRow == emptyRow + 1));
  }

  void _makeMove(int tileIndex) {
    if (!_isValidMove(tileIndex)) return;

    setState(() {
      int emptyIndex = currentGrid.indexOf(gridSize * gridSize - 1);
      int temp = currentGrid[tileIndex];
      currentGrid[tileIndex] = currentGrid[emptyIndex];
      currentGrid[emptyIndex] = temp;
      moveCount++;
      _checkCompletion();
    });
    _saveGame();
  }

  void _checkCompletion() {
    bool solved = true;
    for (int i = 0; i < currentGrid.length - 1; i++) {
      if (currentGrid[i] != i) {
        solved = false;
        break;
      }
    }
    if (solved) {
      // Stop the stopwatch when game is completed
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _baseElapsed += _stopwatch.elapsed;
        _stopwatch.reset();
      }

      setState(() {
        isCompleted = true;
      });

      // Save the game before navigating
      _saveGame();

      // Pass move count and elapsed time to GameEndPage
      Navigator.pushNamed(context, '/game_end', arguments: {
        'moveCount': moveCount,
        'elapsedTime': getCurrentElapsed(),
        'image': imageTiles,
      });
    }
  }

  // Returns total elapsed time: saved time plus current stopwatch time.
  Duration getCurrentElapsed() {
    return _baseElapsed + _stopwatch.elapsed;
  }

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
        body: const Center(child: CircularProgressIndicator()),
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
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MyGameAppBar(
        title: 'Taquin ${gridSize}x$gridSize',
        onBack: () async {
          if (_stopwatch.isRunning) {
            _stopwatch.stop();
            _baseElapsed += _stopwatch.elapsed;
            _stopwatch.reset();
          }
          await _saveGame();
          // Instead of popping, push a named route (e.g., '/home')
          if (context.mounted) Navigator.pushNamed(context, '/home');
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                    ? const SizedBox()
                                    : imageTiles.isNotEmpty &&
                                            tileValue < imageTiles.length
                                        ? Image.memory(
                                            imageTiles[tileValue],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              print(
                                                  'Error loading image: $error');
                                              return Container(
                                                color: Colors.primaries[
                                                    tileValue %
                                                        Colors
                                                            .primaries.length],
                                                child: Center(
                                                  child: Text(
                                                    '${tileValue + 1}',
                                                    style: const TextStyle(
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
                                                style: const TextStyle(
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
