import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/basket_controller.dart';
import '../../../widgets/nav_note_card.dart';

/// Account section — shows a sign-in prompt or the user's profile.
///
/// GetX concepts demonstrated:
///
/// • **Obx drives UI**: `auth.isLoggedIn` is the single source of truth.
///   Switching between sign-in and profile views is fully reactive.
///
/// • **Sign-out without navigation**: logout updates `isLoggedIn`; this
///   widget (and [BasketScreen]) rebuild automatically via `Obx`.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Obx(
        () => auth.isLoggedIn.value
            ? _buildProfile(context, auth)
            : _buildSignIn(auth),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, AuthController auth) {
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
            await auth.logout();
            Get.find<BasketController>().clear();
          },
          child: const Text('Sign Out'),
        ),
        const SizedBox(height: 24),
        const NavNoteCard(
          title: 'GetX: reactive state, no navigation on sign-out',
          body:
              'Logging out updates auth.isLoggedIn. This widget and '
              'BasketScreen both use Obx and rebuild automatically '
              '— no Get.back() or setState() required.',
        ),
      ],
    );
  }

  Widget _buildSignIn(AuthController auth) {
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
              onPressed: auth.navigateToLogin,
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'GetX navigation + reactive auth',
            body:
                'Get.toNamed(login) navigates without BuildContext. '
                'When LoginScreen calls Get.back(result: true), '
                'auth.isLoggedIn is already updated — this widget '
                'rebuilds on its own.',
          ),
        ],
      ),
    );
  }
}
