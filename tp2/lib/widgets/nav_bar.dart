import 'package:flutter/material.dart';

class MyNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MyNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.history),
          label: 'Historique',
        ),
        NavigationDestination(
          icon: Icon(Icons.games),
          label: 'Games',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        onTap(index); // Keep the original callback

        // Navigate based on the selected index
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/history');
            break;
          case 1:
            Navigator.pushNamed(
                context, '/home'); // Assuming Games leads to home page
            break;
          case 2:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
