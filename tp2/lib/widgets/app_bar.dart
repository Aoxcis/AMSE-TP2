import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            // Action ou navigation quand on appuie sur l'icône
          },
        ),
      ],
    );
  }

  // Indique la taille préférée pour la barre d'application
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
