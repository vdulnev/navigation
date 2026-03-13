import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../../shop/services/basket_service.dart';

/// Account tab — shows a sign-in prompt or the user's profile depending on
/// authentication state.
///
/// Navigator 1 concepts demonstrated:
///
/// • **rootNavigator: true** — the Sign In button pushes `/login` above the
///   entire tab scaffold by targeting the MaterialApp's root Navigator.
///
/// • **setState after pop** — when the login modal closes this screen calls
///   `setState()` to rebuild and display the authenticated profile view.
///   No state management library is required for this simple pattern.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _signIn() async {
    final loggedIn =
        await Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(AppRoutes.login)
            as bool?;
    if (loggedIn == true && mounted) setState(() {});
  }

  Future<void> _signOut() async {
    await AuthService.logout();
    BasketService.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: AuthService.isLoggedIn ? _buildProfile() : _buildSignIn(),
    );
  }

  Widget _buildProfile() {
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
        OutlinedButton(onPressed: _signOut, child: const Text('Sign Out')),
        const SizedBox(height: 24),
        const NavNoteCard(
          title: 'Navigator 1: setState after pop',
          body:
              'This screen rebuilds after the login modal closes by calling '
              'setState() when pushNamed returns true. Signing out clears the '
              'basket and calls setState() to switch back to the sign-in view.',
        ),
      ],
    );
  }

  Widget _buildSignIn() {
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
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 24),
          const NavNoteCard(
            title: 'Navigator 1: rootNavigator: true',
            body:
                'Sign In uses rootNavigator: true to push /login on the '
                'MaterialApp\'s Navigator — it slides over the entire tab '
                'scaffold as a fullscreen dialog.',
          ),
        ],
      ),
    );
  }
}
