import 'package:flutter/material.dart';

class Exo4Page extends StatelessWidget {
  const Exo4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercice 4, Display a Tile as a Cropped Image'),
      ),
      body: Center(
        child: DisplayTileWidget(),
      ),
    );
  }
}

class Tile {
  String imageURL;
  Alignment alignment;

  Tile({required this.imageURL, required this.alignment});

  Widget croppedImageTile() {
    return FittedBox(
      fit: BoxFit.fill,
      child: ClipRect(
        child: Align(
          alignment: alignment,
          widthFactor: 0.3,
          heightFactor: 0.3,
          child: Image.asset(imageURL),
        ),
      ),
    );
  }
}

Tile tile = Tile(
    imageURL: '../../assets/exo2.jpg', alignment: Alignment(0, 0));

class DisplayTileWidget extends StatelessWidget {
  const DisplayTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(children: [
        SizedBox(
            width: 150.0,
            height: 150.0,
            child: Container(
                margin: EdgeInsets.all(20.0),
                child: createTileWidgetFrom(tile))),
        SizedBox(height: 200, child: Image.asset('../../assets/exo2.jpg'))
      ])),
    );
  }

  Widget createTileWidgetFrom(Tile tile) {
    return InkWell(
      child: tile.croppedImageTile(),
      onTap: () {
        //print("tapped on tile");
      },
    );
  }
}