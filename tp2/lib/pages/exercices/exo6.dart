import 'package:flutter/material.dart';
import 'dart:math' as math;

// ==============
// Models
// ==============

math.Random random = math.Random();

class Tile {
  Color? color; // Make nullable to allow empty tile
  bool isEmpty;
  bool isAdjacent;
  int number; // Tile identifier

  Tile(this.color,
      {this.isEmpty = false, this.isAdjacent = false, required this.number});

  Tile.randomColor({required this.number})
      : color = Color.fromARGB(
            255, random.nextInt(255), random.nextInt(255), random.nextInt(255)),
        isEmpty = false,
        isAdjacent = false;

  Tile.empty({required this.number})
      : color = null,
        isEmpty = true,
        isAdjacent = false;
}

// ==============
// Widgets
// ==============

class TileWidget extends StatelessWidget {
  final Tile tile;
  final VoidCallback? onTap;

  const TileWidget(this.tile, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0), // Padding between tiles
      child: GestureDetector(
        onTap: tile.isAdjacent ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            color: tile.isEmpty ? Colors.transparent : tile.color,
            border: tile.isAdjacent
                ? Border.all(color: Colors.red, width: 3.0)
                : Border.all(color: Colors.black12),
          ),
          child: Center(
            child: !tile.isEmpty
                ? Text(
                    '${tile.number}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class Exo6Page extends StatefulWidget {
  const Exo6Page({super.key});

  @override
  State<StatefulWidget> createState() => Exo6PageState();
}

class Exo6PageState extends State<Exo6Page> {
  // Grid dimensions
  final int rows = 4;
  final int columns = 4;

  // Position of empty tile
  late int emptyRow;
  late int emptyCol;

  // List of all tiles
  late List<List<Tile>> tiles;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    // Initialize the grid with random colored tiles
    tiles = List.generate(
        rows,
        (i) => List.generate(
            columns, (j) => Tile.randomColor(number: i * columns + j + 1)));

    // Set one tile as empty (bottom-right by default)
    emptyRow = rows - 1;
    emptyCol = columns - 1;
    tiles[emptyRow][emptyCol] = Tile.empty(number: 0);

    // Mark adjacent tiles
    updateAdjacentTiles();
  }

  void updateAdjacentTiles() {
    // Reset all adjacency statuses
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        tiles[i][j].isAdjacent = false;
      }
    }

    // Mark tiles adjacent to empty tile
    // Check top
    if (emptyRow > 0) {
      tiles[emptyRow - 1][emptyCol].isAdjacent = true;
    }
    // Check bottom
    if (emptyRow < rows - 1) {
      tiles[emptyRow + 1][emptyCol].isAdjacent = true;
    }
    // Check left
    if (emptyCol > 0) {
      tiles[emptyRow][emptyCol - 1].isAdjacent = true;
    }
    // Check right
    if (emptyCol < columns - 1) {
      tiles[emptyRow][emptyCol + 1].isAdjacent = true;
    }
  }

  void moveTile(int row, int col) {
    if (!tiles[row][col].isAdjacent) return;

    setState(() {
      // Swap with empty tile
      final tempTile = tiles[row][col];
      tiles[row][col] = tiles[emptyRow][emptyCol];
      tiles[emptyRow][emptyCol] = tempTile;

      // Update empty position
      emptyRow = row;
      emptyCol = col;

      // Update adjacent tiles
      updateAdjacentTiles();
    });
  }

  void resetGame() {
    setState(() {
      initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle coulissant'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetGame,
            tooltip: 'Redémarrer',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: rows * columns,
            itemBuilder: (context, index) {
              final i = index ~/ columns;
              final j = index % columns;
              return TileWidget(
                tiles[i][j],
                onTap: () => moveTile(i, j),
              );
            },
          ),
        ),
      ),
    );
  }
}
