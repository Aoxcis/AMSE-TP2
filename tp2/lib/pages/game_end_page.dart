import 'package:flutter/material.dart';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/widgets/nav_bar.dart';

class GameEndPage extends StatefulWidget {
  const GameEndPage({super.key});

  @override
  State<GameEndPage> createState() => _GameEndPageState();
}

class _GameEndPageState extends State<GameEndPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Fin de la partie'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Félicitations!'),
            Text('Vous avez complété le jeu!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text('Retourner à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
