import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/services/storage.dart';

class GamePage extends StatefulWidget {
  final Map<String, dynamic> gameData;
  
  const GamePage({super.key, required this.gameData});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late List<int> currentGrid;
  late List<Uint8List> imageTiles;
  late int gridSize;
  late int moveCount;
  late bool isCompleted;
  final StorageService _storage = StorageService();

  @override
  void initState() {
  super.initState();
  
  try {
    // Check if data exists, otherwise use defaults
    if (widget.gameData['currentGrid'] != null && widget.gameData['currentImage'] != null) {
      currentGrid = List<int>.from(widget.gameData['currentGrid']);
      imageTiles = List<Uint8List>.from(widget.gameData['currentImage']);
      
      gridSize = (currentGrid.length == 9) ? 3 : 
                (currentGrid.length == 16) ? 4 : 
                (currentGrid.length == 25) ? 5 : 
                (currentGrid.length == 36) ? 6 : 3;
      
      moveCount = widget.gameData['currentMoves'] ?? 0;
      isCompleted = widget.gameData['isCompleted'] ?? false;
    } else {
      // Set defaults for empty/new game
      gridSize = 3; // Default to 3x3 grid
      currentGrid = List<int>.generate(gridSize * gridSize, (index) => index);
      imageTiles = []; // Empty list as fallback
      moveCount = 0;
      isCompleted = false;
      
      // Debug information
      print('Warning: Game initialized with default values. Game data was incomplete.');
      print('Received game data: ${widget.gameData}');
    }
  } catch (e) {
    // Fallback for any error
    print('Error initializing game: $e');
    gridSize = 3;
    currentGrid = List<int>.generate(gridSize * gridSize, (index) => index);
    imageTiles = [];
    moveCount = 0;
    isCompleted = false;
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
    return (tileRow == emptyRow && (tileCol == emptyCol - 1 || tileCol == emptyCol + 1)) || 
           (tileCol == emptyCol && (tileRow == emptyRow - 1 || tileRow == emptyRow + 1));
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
    final gameId = widget.gameData['id'];
    
    Map<String, dynamic> currentState = {
      'currentGrid': currentGrid,
      'currentMoves': moveCount,
      'currentImage': imageTiles,
      'isCompleted': isCompleted,
    };
    
    await _storage.saveGame(
      gameId, 
      widget.gameData['settings'] ?? {}, 
      currentState
    );
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
              Navigator.of(context).popUntil(ModalRoute.withName('/home'));
            },
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Difficulté: ${widget.gameData["settings"]?["difficulty"] ?? "Normal"}',
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
                      textAlign: TextAlign.center,
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                    ),
                    itemCount: gridSize * gridSize,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final tileIndex = currentGrid[index];
                      final isEmptyTile = tileIndex == gridSize * gridSize - 1;
                      
                      return GestureDetector(
                        onTap: () {
                          if (!isCompleted) {
                            _makeMove(index);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isEmptyTile ? Colors.transparent : Colors.white,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: isEmptyTile 
                              ? const SizedBox() 
                              : Image.memory(
                                  imageTiles[tileIndex],
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          
          // Helper text
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Appuyez sur une tuile adjacente à l'espace vide pour la déplacer",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}