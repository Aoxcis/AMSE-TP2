import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/widgets/nav_bar.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:app_settings/app_settings.dart';
import 'package:tp2/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: const MyAppBar(title: 'Paramètres'),
      body: SettingsList(sections: [
        SettingsSection(
          title: Text('Général'),
          tiles: [
            SettingsTile.switchTile(
                initialValue: themeProvider.isDarkMode,
                onToggle: (bool value) {
                  themeProvider.toggleTheme();
                },
                title: Text('Mode Sombre'),
                leading: Icon(Icons.nightlight_round)),
            SettingsTile(
              title: Text('Autorisations'),
              leading: Icon(Icons.security),
              onPressed: (BuildContext context) {
                AppSettings.openAppSettings();
              },
            ),
          ],
        ),
      ]),
      bottomNavigationBar: MyNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}