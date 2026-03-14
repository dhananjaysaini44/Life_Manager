import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'providers/database_providers.dart';
import 'providers/settings_provider.dart';
import 'data/seed_data.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final sharedPreferences = await SharedPreferences.getInstance();
    
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );
    
    final db = container.read(databaseProvider);
    await SeedDataService(db).seedIfNeeded();

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const LifeManagerApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('Error during app initialization: $e');
    debugPrint(stack.toString());
    // Fallback app to show error if initialization fails
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Initialization Error: $e')))));
  }
}

class LifeManagerApp extends ConsumerWidget {
  const LifeManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'Life Manager',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: AppTheme.light(lightDynamic, seedColor: settings.seedColor),
          darkTheme: AppTheme.dark(darkDynamic, seedColor: settings.seedColor),
          routerConfig: router,
        );
      },
    );
  }
}
