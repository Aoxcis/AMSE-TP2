import 'package:flutter/material.dart';

class GridOverlay extends StatelessWidget {
  final int gridSize;
  
  const GridOverlay({super.key, required this.gridSize});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Draw vertical lines
            for (int i = 1; i < gridSize; i++)
              Positioned(
                left: i * constraints.maxWidth / gridSize,
                top: 0,
                bottom: 0,
                width: 2,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            // Draw horizontal lines  
            for (int i = 1; i < gridSize; i++)
              Positioned(
                top: i * constraints.maxHeight / gridSize,
                left: 0,
                right: 0,
                height: 2,
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
          ],
        );
      },
    );
  }
}