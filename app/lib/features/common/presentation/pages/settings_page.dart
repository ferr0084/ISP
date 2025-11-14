import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart'; // Import ThemeProvider

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).appBarTheme.foregroundColor),
        ),
      ),
      body: ListView(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              );
            },
          ),
          // Add other settings options here
        ],
      ),
    );
  }
}