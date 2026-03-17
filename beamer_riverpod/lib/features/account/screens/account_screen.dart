import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/screens/login_screen.dart';
import '../../logs/screens/logs_screen.dart';

/// Account section — shows a sign-in prompt or the user's profile.
///
/// Beamer + Riverpod concepts demonstrated:
///
/// • **Riverpod watch drives UI**: `ref.watch(authProvider)` is the single
///   source of truth. Switching between views is fully reactive.
///
/// • **Sign-out without navigation**: logout updates [authProvider]; the
///   basket delegate's [BeamGuard] will intercept checkout on next visit.
///   [ShellScreen] listens to [authProvider] and resets the basket stack.
///   No explicit navigation call needed from this screen.
///
/// • **Logs push via root Navigator**: `/logs` is defined on the root
///   delegate so it covers the entire screen (shell chrome hidden).
///   `Navigator.of(context, rootNavigator: true).pushNamed(logs)` is
///   used to break out of the account tab's navigator.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: isLoggedIn ? _buildProfile(context, ref) : _buildSignIn(context),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(
          child: CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Welcome back!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),
        Builder(
          builder: (context) => ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('user@example.com'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            ref.read(basketProvider.notifier).clear();
            // No navigation call needed — ShellScreen listens to authProvider
            // and resets the basket delegate stack automatically.
          },
          child: const Text('Sign Out'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(builder: (_) => const LogsScreen()),
          ),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('View Logs'),
        ),
        const SizedBox(height: 24),
        const NavNoteCard(
          title: 'Talker: Beamer + Riverpod logging',
          body:
              'TalkerRiverpodObserver logs every provider state change. '
              'rootNavigator.pushNamed(logs) breaks out of the account tab '
              'navigator to show LogsScreen over the full screen.',
        ),
      ],
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Sign in to your account', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).push<bool>(
                MaterialPageRoute<bool>(
                  fullscreenDialog: true,
                  builder: (_) => const LoginScreen(),
                ),
              ),
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'Beamer: rootNavigator.pushNamed for modal login',
            body:
                'rootNavigator.pushNamed(login) presents LoginScreen as a '
                'fullscreenDialog over the shell. authProvider updates on '
                'success; this widget rebuilds reactively — no return '
                'value needed here.',
          ),
        ],
      ),
    );
  }
}
