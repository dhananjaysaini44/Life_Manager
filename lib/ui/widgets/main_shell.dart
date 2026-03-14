import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'quick_add_sheet.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  // Maps NavigationBar index to StatefulShellBranch index
  int _navToBranch(int index) {
    if (index < 2) return index;
    if (index > 2) return index - 1;
    return -1; // FAB index (2)
  }

  // Maps StatefulShellBranch index to NavigationBar index
  int _branchToNav(int index) {
    if (index < 2) return index;
    return index + 1;
  }

  void _onTap(int index) {
    final branchIndex = _navToBranch(index);
    if (branchIndex == -1) return; // Ignore FAB tap

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _branchToNav(navigationShell.currentIndex),
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: SizedBox.shrink(),
            label: '',
            enabled: false,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const QuickAddBottomSheet(),
            );
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}
