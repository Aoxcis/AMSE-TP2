import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import 'package:tp2/services/storage.dart';

class GameCreationService {
  // Singleton pattern
  static final GameCreationService _instance = GameCreationService._internal();
  factory GameCreationService() => _instance;
  GameCreationService._internal();
  final storageService = StorageService();

  /// Creates a new game based on the provided options
  Future<Map<String, dynamic>> createGame(
      Map<String, dynamic> gameOptions) async {
    final int gridSize = gameOptions['gridSize'] ?? 3;
    final String difficulty = gameOptions['difficulty'] ?? 'Facile';
    final dynamic imageSource =
        gameOptions['image']; // Could be File or String URL

    // Prepare image data
    final imageTiles = await _sliceImage(imageSource, gridSize);
    final shuffledGrid = _shuffleGrid(gridSize, difficulty);

    Map<String, dynamic> gameSettings = {
      'gridSize': gridSize,
      'difficulty': difficulty,
      'image': imageSource,
    };

    Map<String, dynamic> gameState = {
      'id': -1,
      'currentGrid': shuffledGrid,
      'currentMoves': [],
      'currentImage': imageTiles,
      'isCompleted': false,
    };

    int id = await storageService.saveGame(-1, gameSettings, gameState);

    gameState['id'] = id;

    return gameState;
  }

  /// Slices the provided image into a grid of tiles
  Future<List<Uint8List>> _sliceImage(dynamic imageSource, int gridSize) async {
    if (imageSource == null) {
      // Use a placeholder or default image if none provided
      return _generatePlaceholderImages(gridSize);
    }

    try {
      ui.Image image;

      if (imageSource is File) {
        // Load image from file
        final bytes = await imageSource.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        image = frame.image;
      } else if (imageSource is String) {
        // Load image from URL
        final NetworkImage networkImage = NetworkImage(imageSource);
        final ImageStream stream =
            networkImage.resolve(ImageConfiguration.empty);
        final Completer<ui.Image> completer = Completer<ui.Image>();

        final listener = ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
        }, onError: (dynamic error, StackTrace? stackTrace) {
          completer.completeError(error);
        });

        stream.addListener(listener);
        image = await completer.future;
        stream.removeListener(listener);
      } else {
        return _generatePlaceholderImages(gridSize);
      }

      // Get image dimensions
      final int width = image.width;
      final int height = image.height;
      final int tileWidth = width ~/ gridSize;
      final int tileHeight = height ~/ gridSize;

      List<Uint8List> tiles = [];

      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          // Create a PictureRecorder for each tile
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);

          // Paint the portion of the image for this tile
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(x * tileWidth.toDouble(), y * tileHeight.toDouble(),
                tileWidth.toDouble(), tileHeight.toDouble()),
            Rect.fromLTWH(0, 0, tileWidth.toDouble(), tileHeight.toDouble()),
            Paint(),
          );

          // Convert to an image
          final picture = recorder.endRecording();
          final tileImage = await picture.toImage(tileWidth, tileHeight);
          final byteData =
              await tileImage.toByteData(format: ui.ImageByteFormat.png);

          tiles.add(byteData!.buffer.asUint8List());
        }
      }

      // Add a blank tile at the end (traditionally the bottom-right corner)
      tiles.add(await _createBlankTile(tileWidth, tileHeight));

      return tiles;
    } catch (e) {
      print('Error slicing image: $e');
      return _generatePlaceholderImages(gridSize);
    }
  }

  /// Create a blank tile (for the empty space)
  Future<Uint8List> _createBlankTile(int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw a transparent rectangle
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = Colors.transparent,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Generate placeholder colored tiles if no image is provided
  Future<List<Uint8List>> _generatePlaceholderImages(int gridSize) async {
    List<Uint8List> tiles = [];
    final int tileSize = 100; // Default size for placeholders

    for (int i = 0; i < gridSize * gridSize - 1; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Use a different color for each tile
      canvas.drawRect(
        Rect.fromLTWH(0, 0, tileSize.toDouble(), tileSize.toDouble()),
        Paint()..color = Colors.primaries[i % Colors.primaries.length],
      );

      // Add the tile number
      final textPainter = TextPainter(
        text: TextSpan(
          text: (i + 1).toString(),
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset((tileSize - textPainter.width) / 2,
              (tileSize - textPainter.height) / 2));

      final picture = recorder.endRecording();
      final image = await picture.toImage(tileSize, tileSize);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      tiles.add(byteData!.buffer.asUint8List());
    }

    // Add blank tile
    tiles.add(await _createBlankTile(tileSize, tileSize));

    return tiles;
  }

  /// Shuffles the grid according to the difficulty level
  List<int> _shuffleGrid(int gridSize, String difficulty) {
    // Create the solved grid first (0 to gridSize^2 - 1)
    List<int> grid = List.generate(gridSize * gridSize, (index) => index);
    final emptyTileIndex = gridSize * gridSize - 1; // Last tile is empty

    // Determine number of random moves based on difficulty
    int moves;
    switch (difficulty) {
      case 'Facile':
        moves = gridSize * 10;
        break;
      case 'Moyen':
        moves = gridSize * 20;
        break;
      case 'Difficile':
        moves = gridSize * 40;
        break;
      default:
        moves = gridSize * 10;
    }

    // Make random valid moves to shuffle
    Random random = Random();
    int lastDirection = -1; // To avoid immediate reversals
    int currentEmptyPos = emptyTileIndex;

    for (int i = 0; i < moves; i++) {
      List<int> validMoves =
          _getValidMoves(currentEmptyPos, gridSize, lastDirection);
      if (validMoves.isEmpty) continue;

      int direction = validMoves[random.nextInt(validMoves.length)];
      int tileToMove = _getTileToMove(currentEmptyPos, direction, gridSize);

      // Swap the empty tile with the selected tile
      grid[currentEmptyPos] = grid[tileToMove];
      grid[tileToMove] = emptyTileIndex;
      currentEmptyPos = tileToMove;
      lastDirection = (direction + 2) % 4; // Store the opposite direction
    }

    // Ensure the puzzle is solvable
    if (!_isSolvable(grid, gridSize)) {
      // Swap any two non-empty tiles to make it solvable
      int pos1 = 0;
      int pos2 = 1;
      while (grid[pos1] == emptyTileIndex) pos1++;
      while (grid[pos2] == emptyTileIndex || pos2 == pos1) pos2++;

      int temp = grid[pos1];
      grid[pos1] = grid[pos2];
      grid[pos2] = temp;
    }

    return grid;
  }

  // Directions: 0 = up, 1 = right, 2 = down, 3 = left
  List<int> _getValidMoves(int emptyPos, int gridSize, int lastDirection) {
    List<int> validDirections = [];

    // Check up
    if (emptyPos >= gridSize && lastDirection != 2) {
      validDirections.add(0);
    }
    // Check right
    if (emptyPos % gridSize < gridSize - 1 && lastDirection != 3) {
      validDirections.add(1);
    }
    // Check down
    if (emptyPos < gridSize * (gridSize - 1) && lastDirection != 0) {
      validDirections.add(2);
    }
    // Check left
    if (emptyPos % gridSize > 0 && lastDirection != 1) {
      validDirections.add(3);
    }

    return validDirections;
  }

  int _getTileToMove(int emptyPos, int direction, int gridSize) {
    switch (direction) {
      case 0:
        return emptyPos - gridSize; // Tile above
      case 1:
        return emptyPos + 1; // Tile to the right
      case 2:
        return emptyPos + gridSize; // Tile below
      case 3:
        return emptyPos - 1; // Tile to the left
      default:
        return emptyPos;
    }
  }

  // Check if the puzzle is solvable using the inversion count method
  bool _isSolvable(List<int> grid, int gridSize) {
    int inversions = 0;
    int emptyTileRow = 0;
    final emptyTileValue = gridSize * gridSize - 1;

    // Find the empty tile's row
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == emptyTileValue) {
        emptyTileRow = i ~/ gridSize;
        break;
      }
    }

    // Count inversions
    for (int i = 0; i < grid.length - 1; i++) {
      if (grid[i] == emptyTileValue) continue;

      for (int j = i + 1; j < grid.length; j++) {
        if (grid[j] != emptyTileValue && grid[i] > grid[j]) {
          inversions++;
        }
      }
    }

    // For odd grid sizes
    if (gridSize % 2 == 1) {
      return inversions % 2 == 0;
    }
    // For even grid sizes
    else {
      return (inversions + emptyTileRow) % 2 == 1;
    }
  }
}
