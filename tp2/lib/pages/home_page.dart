import 'package:flutter/material.dart';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/widgets/nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Ici, tu peux gérer la navigation en fonction de l'index sélectionné
    // par exemple avec un switch ou un Navigator.push()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Taquin'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 150),
                textStyle: const TextStyle(fontSize: 30),
              ),
              onPressed: () {
                // Naviguer vers la page de jeu
              },
              child: const Text('Jouer'),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 150),
                textStyle: const TextStyle(fontSize: 30),
              ),
              onPressed: () {
                // Naviguer vers la page quotidienne
              },
              child: const Text('Daily'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
