import 'package:flutter/material.dart';

class MyGameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyGameAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.home),
            onPressed: () { 
              Navigator.pushNamed(
                context,
                '/home',
              );
            },
          );
        },
      ),
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            Navigator.pushNamed(context, '/info');
          },
        ),
      ],
    );
  }

  // Indique la taille préférée pour la barre d'application
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}