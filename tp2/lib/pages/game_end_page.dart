import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/services/storage.dart';

class GameEndPage extends StatefulWidget {
  const GameEndPage({super.key});

  @override
  State<GameEndPage> createState() => _GameEndPageState();
}

class _GameEndPageState extends State<GameEndPage> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  String? _imageData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOriginalImage();
    });
  }

  Future<void> _loadOriginalImage() async {
    print('trying to load original image');
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    final int gameId = args['gameId'] ?? -1;

    if (gameId != -1) {
      try {
        // Use the storage service's getImage method to retrieve the full image
        final originalImage = await _storage.getImage(gameId);
        setState(() {
          _imageData = originalImage;
          _isLoading = false;
        });
        return;
      } catch (e) {
        print('Error loading original image: $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Receive the arguments passed from GamePage
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    // Extract move count and elapsed time
    final int moveCount = args['moveCount'] ?? 0;
    final Duration elapsedTime = args['elapsedTime'] ?? Duration.zero;

    // Format elapsed time
    final int minutes = elapsedTime.inMinutes;
    final int seconds = elapsedTime.inSeconds % 60;

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

              // Display the full original image from storage
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildImage(),
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

  Widget _buildImage() {
    if (_imageData == null) {
      return _buildErrorImage();
    }

    // First, try to load as a Base64 string
    try {
      // Check if it looks like a base64 string
      if (_imageData!.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
        Uint8List imageBytes = base64Decode(_imageData!);
        return Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('Failed to load as base64: $error');
            return _tryAlternativeFormats();
          },
        );
      }
      return _tryAlternativeFormats();
    } catch (e) {
      print('Error decoding image as base64: $e');
      return _tryAlternativeFormats();
    }
  }

  Widget _tryAlternativeFormats() {
    // Try to load as a network URL
    if (_imageData!.startsWith('http://') ||
        _imageData!.startsWith('https://')) {
      return Image.network(
        _imageData!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load as network image: $error');
          return _buildErrorImage();
        },
      );
    }
    // Try to load as a file path
    else if (_imageData!.startsWith('/')) {
      return Image.file(
        File(_imageData!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load as file image: $error');
          return _buildErrorImage();
        },
      );
    }
    // Try as asset path
    else if (_imageData!.startsWith('assets/')) {
      return Image.asset(
        _imageData!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load as asset image: $error');
          return _buildErrorImage();
        },
      );
    }
    // If we don't recognize the format, show error
    else {
      print('Unknown image format: $_imageData');
      return _buildErrorImage();
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'Image non disponible',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
