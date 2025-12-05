// Auth wrapper to handle navigation based on auth state
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/storage/hive_service.dart';
import 'main_nav.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _promptShown = false;

  void _maybeShowSignInPrompt(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Use settings box to persist that user has seen the prompt
    final settingsBox = HiveService.getSettingsBox();
    final alreadyPrompted = settingsBox.get('prompt_signin_shown') == true;

    if (_promptShown || alreadyPrompted) return;

    if (authProvider.currentUser == null) {
      _promptShown = true;
      // schedule after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Sign in to backup and sync your data across devices. Use the account icon in the navigation bar.',
            ),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                settingsBox.put('prompt_signin_shown', true);
              },
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show main navigation; Auth UI is available via top-right avatar
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeShowSignInPrompt(context),
    );
    return const MainNavigation();
  }
}
