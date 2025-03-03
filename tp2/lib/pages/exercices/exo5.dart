import 'package:flutter/material.dart';
import 'dart:math';

class Exo5Page extends StatefulWidget {
  const Exo5Page({super.key});

  @override
  _Exo5PageState createState() => _Exo5PageState();
}

class _Exo5PageState extends State<Exo5Page> {
  int _currentPage = 0;
  int _gridSize = 3;

  void _selectPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercice 5'),
        actions: [
          PopupMenuButton<int>(
            onSelected: _selectPage,
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text('Page 1')),
              PopupMenuItem(value: 1, child: Text('Page 2')),
              PopupMenuItem(value: 2, child: Text('Page 3')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildPageContent(),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentPage) {
      case 0:
        return _buildGridViewWithTiles();
      case 1:
        return _buildGridViewWithImage();
      case 2:
        return _buildSliderPage();
      default:
        return Center(child: Text('Page not found'));
    }
  }

  Widget _buildGridViewWithTiles() {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                .withAlpha(255),
            child: Center(child: Text('Tile ${index + 1}')),
          ),
        );
      },
      itemCount: 9,
    );
  }

  Widget _buildGridViewWithImage() {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        int row = index ~/ 3;
        int col = index % 3;
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRect(
            child: Align(
              alignment: FractionalOffset(col / 3.0, row / 3.0),
              widthFactor: 1 / 3.0,
              heightFactor: 1 / 3.0,
              child: FractionallySizedBox(
                widthFactor: 3.0,
                heightFactor: 3.0,
                child: Image.asset(
                  '../../assets/exo2.jpg',
                  fit: BoxFit.none,
                  alignment: Alignment(-1 + col * 2 / 2, -1 + row * 2 / 2),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: 9,
    );
  }

  Widget _buildSliderPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridSize),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  color: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                      .withOpacity(1.0),
                  child: Center(child: Text('Tile ${index + 1}')),
                ),
              );
            },
            itemCount: _gridSize * _gridSize,
          ),
        ),
        Slider(
          value: _gridSize.toDouble(),
          min: 2,
          max: 10,
          divisions: 8,
          label: 'Grid Size: $_gridSize',
          onChanged: (value) {
            setState(() {
              _gridSize = value.toInt();
            });
          },
        ),
      ],
    );
  }
}
