import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tp2/widgets/app_bar.dart';
import 'package:tp2/widgets/nav_bar.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      appBar: const MyAppBar(title: 'Paramètres'),
      body: SettingsList(sections: [
        SettingsSection(
          title: Text('Général'),
          tiles: [
            SettingsTile.switchTile(
                initialValue: false,
                onToggle: (bool value) {},
                title: Text('Mode Sombre'),
                leading: Icon(Icons.nightlight_round)),
            SettingsTile(
              title: Text('Autorisations'),
              leading: Icon(Icons.security),
              onPressed: (BuildContext context) {
                Future<void> openAppSettings() async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    await launchUrl(Uri.parse('app-settings:'));
                  }
                }

                openAppSettings();
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
