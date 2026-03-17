import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Account section — shows a sign-in prompt or the user's profile.
///
/// Navigator 2 concept: all navigation is via [NavigationNotifier].
/// - "Sign In" → [NavigationNotifier.showLogin] pushes LoginScreen on the
///   root Navigator. [authProvider] updates on success; this widget rebuilds.
/// - "View Logs" → [NavigationNotifier.showLogs] pushes LogsScreen on the
///   root Navigator.
/// - Sign out: [AuthNotifier.logout] + [NavigationNotifier.onLogout] clear
///   basket state; [authProvider] changing triggers a reactive rebuild.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: isLoggedIn ? _buildProfile(ref) : _buildSignIn(ref),
    );
  }

  Widget _buildProfile(WidgetRef ref) {
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
            ref.read(navigationProvider.notifier).onLogout();
          },
          child: const Text('Sign Out'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.read(navigationProvider.notifier).showLogs(),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('View Logs'),
        ),
        const SizedBox(height: 24),
        const NavNoteCard(
          title: 'Talker: Navigator 2 + Riverpod logging',
          body:
              'TalkerNavigatorObserver logs every navigation event per '
              'Navigator (root, shop, search, basket, account). '
              'TalkerRiverpodObserver logs every provider state change. '
              'Tap "View Logs" to open the in-app log viewer.',
        ),
      ],
    );
  }

  Widget _buildSignIn(WidgetRef ref) {
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
              onPressed: () =>
                  ref.read(navigationProvider.notifier).showLogin(),
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'Navigator 2: showLogin() via NavigationNotifier',
            body:
                'showLogin() sets NavigationState.showLogin = true. The root '
                'Navigator diffs its page list and pushes LoginScreen as a '
                'fullscreenDialog. authProvider updates on success; this '
                'widget rebuilds reactively — no return value needed.',
          ),
        ],
      ),
    );
  }
}
