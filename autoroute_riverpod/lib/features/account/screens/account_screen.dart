import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/nav_note_card.dart';

/// Account section — shows a sign-in prompt or the user's profile.
///
/// AutoRoute concepts demonstrated:
///
/// * **Riverpod watch drives UI**: `ref.watch(authProvider)` is the single
///   source of truth. Switching between views is fully reactive.
///
/// * **Sign-out without navigation**: logout updates [authProvider]; the UI
///   rebuilds reactively. [ShellScreen] resets the basket stack via
///   `stackRouterOfIndex(2)?.popUntilRoot()` — no explicit navigation needed.
@RoutePage()
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
          },
          child: const Text('Sign Out'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.router.push(const LogsRoute()),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('View Logs'),
        ),
        const SizedBox(height: 24),
        const NavNoteCard(
          title: 'Talker: AutoRoute + Riverpod logging',
          body:
              'TalkerRouteObserver logs every push/pop via navigatorObservers. '
              'TalkerRiverpodObserver logs every provider state change. '
              'Tap "View Logs" to open TalkerScreen.',
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
              onPressed: () => context.router.push(const LoginRoute()),
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'AutoRoute: context.router.push for modal login',
            body:
                'context.router.push(LoginRoute()) presents LoginScreen as a '
                'fullscreenDialog. authProvider updates on success; this widget '
                'rebuilds reactively via ref.watch — no return value needed here.',
          ),
        ],
      ),
    );
  }
}
