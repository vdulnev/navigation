import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/basket_provider.dart';
import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';

/// Account section — shows a sign-in prompt or the user's profile.
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **Riverpod watch drives UI**: `ref.watch(authProvider)` is the single
///   source of truth. Switching between sign-in and profile views is fully
///   reactive — no setState needed anywhere.
///
/// • **Sign-out without navigation**: logout updates [authProvider] state;
///   this widget (and [BasketScreen]) rebuild automatically. No route change
///   needed — the user stays in the Account tab.
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
    return Builder(
      builder: (context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Welcome back!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('user@example.com'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              ref.read(basketProvider.notifier).clear();
              // No navigation — authProvider state change rebuilds this widget.
            },
            child: const Text('Sign Out'),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'Riverpod: reactive state, no navigation on sign-out',
            body:
                'Logging out updates authProvider state. This widget and '
                'BasketScreen both watch authProvider and rebuild '
                'automatically — no Get.back() or setState() required.',
          ),
        ],
      ),
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
              onPressed: () => Get.toNamed(AppRoutes.login),
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'GetX navigation + Riverpod reactive auth',
            body:
                'Get.toNamed(login) navigates without BuildContext. '
                'When LoginScreen calls Get.back(result: true), authProvider '
                'state is already updated — this widget rebuilds on its own.',
          ),
        ],
      ),
    );
  }
}
