import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/auth.dart';
import '../providers/theme_notifier.dart';

class CustomDrawer extends StatelessWidget {
  final void Function(int) selectIndex;
  final int selectedIndex;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.selectIndex,
  });

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeModeDialog(BuildContext context, ThemeNotifier themeNotifier) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Select Theme',
            style: textTheme.titleLarge?.copyWith(color: onSurfaceColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                title: Text(
                  _getThemeModeText(mode),
                  style: textTheme.bodyMedium?.copyWith(color: onSurfaceColor),
                ),
                value: mode,
                groupValue: themeNotifier.themeMode,
                onChanged: (newMode) {
                  if (newMode != null) {
                    themeNotifier.setThemeMode(newMode);
                    Navigator.of(ctx).pop();
                  }
                },
                activeColor: primaryColor,
              );
            }).toList(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: surfaceColor,
        );
      },
    );
  }

  // Function to show logout confirmation dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Confirm Logout',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            content: Text(
              'Are you sure you want to log out?',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false; // Return false if the dialog is dismissed

    if (confirm && context.mounted) {
      final showSnackBar = ScaffoldMessenger.of(context).showSnackBar;
      final colorScheme = Theme.of(context).colorScheme;

      await AuthServices().signOut();
      showSnackBar(
        SnackBar(
          content: const Text('Logged out!'),
          backgroundColor: colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: Container(
        color: colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorScheme.primary,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: colorScheme.surface,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome!',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userEmail != null)
                      Text(
                        userEmail,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notes,
                      color: selectedIndex == 0
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    title: Text(
                      'Notes',
                      style: textTheme.titleMedium?.copyWith(
                        color: selectedIndex == 0
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.9),
                        fontWeight: selectedIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: selectedIndex == 0,
                    selectedTileColor:
                        colorScheme.primary.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pop();
                      selectIndex(0);
                    },
                  ).animate(effects: [
                    FadeEffect(duration: 300.ms),
                    SlideEffect(begin: Offset(-0.1, 0))
                  ]),
                  ListTile(
                    leading: Icon(
                      Icons.task_alt,
                      color: selectedIndex == 1
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    title: Text(
                      'To-Dos',
                      style: textTheme.titleMedium?.copyWith(
                        color: selectedIndex == 1
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.9),
                        fontWeight: selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    selected: selectedIndex == 1,
                    selectedTileColor:
                        colorScheme.primary.withValues(alpha: 0.1),
                    onTap: () {
                      Navigator.of(context).pop();
                      selectIndex(1);
                    },
                  ).animate(effects: [
                    FadeEffect(duration: 300.ms, delay: 50.ms),
                    SlideEffect(begin: Offset(-0.1, 0), delay: 50.ms)
                  ]),
                  const Divider(height: 32, thickness: 1),
                  ListTile(
                    leading: Icon(
                      Icons.brightness_medium,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      'Theme',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      _getThemeModeText(themeNotifier.themeMode),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    onTap: () {
                      _showThemeModeDialog(context, themeNotifier);
                    },
                  ).animate(effects: [
                    FadeEffect(duration: 300.ms, delay: 100.ms),
                    SlideEffect(begin: Offset(-0.1, 0), delay: 100.ms)
                  ]),
                  const Divider(height: 32, thickness: 1),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: colorScheme.error,
                    ),
                    title: Text(
                      'Logout',
                      style: textTheme.titleMedium
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                    onTap: () {
                      // Call the confirmation dialog
                      _confirmLogout(context);
                    },
                  ).animate(effects: [
                    FadeEffect(duration: 300.ms, delay: 150.ms),
                    SlideEffect(begin: Offset(-0.1, 0), delay: 150.ms)
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
