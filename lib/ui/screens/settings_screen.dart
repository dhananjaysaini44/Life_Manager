import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/database_providers.dart';
import '../../data/seed_data.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.name.toUpperCase()),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_outlined)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (newSelection) {
                ref.read(settingsProvider.notifier).setThemeMode(newSelection.first);
              },
              showSelectedIcon: false,
            ),
          ),
          ListTile(
            title: const Text('App Color'),
            subtitle: const Text('Change the primary seed color'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: settings.seedColor,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
            ),
            onTap: () => _showColorPickerDialog(context, ref),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Data'),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
            onTap: () => _showClearDataConfirmation(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.refresh_outlined),
            title: const Text('Re-insert Sample Data'),
            onTap: () async {
              final db = ref.read(databaseProvider);
              await SeedDataService(db).seedIfNeeded();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample data re-inserted.')),
                );
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          const ListTile(
            title: Text('App Version'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('Made with Flutter & Material You'),
            subtitle: Text('A personal productivity assistant'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context, WidgetRef ref) {
    final colors = [
      const Color(0xFF22C55E), // Green
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select App Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              ref.read(settingsProvider.notifier).setSeedColor(color);
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ref.watch(settingsProvider).seedColor == color 
                      ? Colors.black 
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your tasks, projects, and notes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              // Implementation would involve calling a method on AppDatabase to delete all
              // For now, we'll just show a snackbar as a placeholder if delete methods aren't fully exposed
              // But let's assume we can clear them.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data cleared (feature pending DAO extension)')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
