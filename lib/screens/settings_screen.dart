import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

/// The Settings screen allows users to customize the app's appearance
/// and manage their stored data.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // --- Appearance Section ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          ListTile(
            title: const Text('App Theme'),
            subtitle: Text(_getThemeModeName(taskProvider.themeMode)),
            trailing: const Icon(Icons.brightness_6),
            onTap: () => _showThemeDialog(context, taskProvider),
          ),
          const Divider(),

          // --- Data Management Section ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Data Management',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          ListTile(
            title: const Text('Reset All Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Delete all tasks and events permanently'),
            trailing: const Icon(Icons.delete_sweep, color: Colors.red),
            onTap: () => _showResetConfirmDialog(context, taskProvider),
          ),
          const Divider(),

          // --- About Section ---
          const AboutListTile(
            icon: Icon(Icons.info),
            applicationName: 'Life Manager',
            applicationVersion: '1.0.0',
            aboutBoxChildren: [
              Text('Manage your life Skillfully!!!'),
              SizedBox(height: 10),
              Text('A task and event manager with local notifications.'),
            ],
          ),
        ],
      ),
    );
  }

  /// Maps the ThemeMode enum to a human-readable string.
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  /// Shows a radio-button dialog for theme selection.
  void _showThemeDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              value: ThemeMode.light,
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              value: ThemeMode.dark,
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before wiping all user data.
  void _showResetConfirmDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All?'),
        content: const Text('This will delete all your tasks and events. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.resetAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
