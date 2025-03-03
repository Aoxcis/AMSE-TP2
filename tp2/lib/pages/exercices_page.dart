import 'package:flutter/material.dart';

class ExercicesPage extends StatelessWidget {
  final List<String> exercices = [
    'Exercice 2',
    'Exercice 4',
    'Exercice 5',
    'Exercice 6',
  ];

  ExercicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercices'),
      ),
      body: ListView.builder(
        itemCount: exercices.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: ListTile(
              title: Text(exercices[index]),
              onTap: () {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, '/exo2');
                    break;
                  case 1:
                    Navigator.pushNamed(context, '/exo4');
                    break;
                  case 2:
                    Navigator.pushNamed(context, '/exo5');
                    break;
                  case 3:
                    Navigator.pushNamed(context, '/exo6');
                    break;
                  default:
                    // Handle Exercice 1 or any other cases
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }
}