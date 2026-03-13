import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/nav_note_card.dart';
import '../../auth/services/auth_service.dart';
import '../../shop/services/basket_service.dart';

/// Account section — shows sign-in prompt or profile depending on auth state.
///
/// Navigator 1 concepts demonstrated:
///
/// • **Plain `pushNamed` auth guard** — no `rootNavigator: true` required.
///
/// • **`setState` after pop** — rebuilds to show profile after login.
///
/// • **`pushNamedAndRemoveUntil` on sign-out** — clears the stack and returns
///   to Shop, same mechanism [AppDrawer] uses for section switching.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Future<void> _signIn() async {
    final loggedIn =
        await Navigator.of(context).pushNamed(AppRoutes.login) as bool?;
    if (loggedIn == true && mounted) setState(() {});
  }

  Future<void> _signOut() async {
    await AuthService.logout();
    BasketService.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.shop, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      drawer: const AppDrawer(activeRoute: AppRoutes.account),
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
          title: 'Navigator 1: pushNamedAndRemoveUntil on sign-out',
          body:
              'Sign Out clears the stack with (r) => false and pushes /shop. '
              'The same mechanism AppDrawer uses for section switching.',
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
            title: 'Navigator 1: setState after pop',
            body:
                'pushNamed(/login) awaits the result. When the login screen '
                'pops with true, setState() switches this screen to the '
                'profile view — no state management needed.',
          ),
        ],
      ),
    );
  }
}
