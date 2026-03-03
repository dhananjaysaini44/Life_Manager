import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/tasks_screen.dart';
import 'screens/settings_screen.dart';

/// The main entry point for the application.
void main() {
  // Ensures that Flutter bindings are initialized before any Flutter code is executed.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Runs the app with a ChangeNotifierProvider at the root.
  // This makes the TaskProvider accessible throughout the widget tree.
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listens to the TaskProvider to rebuild when the theme changes.
    final taskProvider = Provider.of<TaskProvider>(context);

    return MaterialApp(
      title: 'Life Manager',
      debugShowCheckedModeBanner: false,

      // --- Theme Configuration ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: taskProvider.themeMode, // Theme is controlled by the provider.

      // The initial screen to be displayed.
      home: const LoadingScreen(),
    );
  }
}

/// A temporary loading screen shown on app startup.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  /// Navigates to the main screen after a short delay.
  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              'Life Manager',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Manage your life Skillfully!!!',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// The main screen that hosts the BottomNavigationBar.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // The list of screens to be displayed in the navigation bar.
  static const List<Widget> _screens = [
    TasksScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Manager',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
