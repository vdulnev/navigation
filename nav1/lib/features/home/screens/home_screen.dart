import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';
import '../../auth/services/auth_service.dart';

/// Hub screen reached after successful login.
///
/// Navigator 1 concepts demonstrated:
/// - [Navigator.pushNamed]: push a new named route onto the stack.
/// - [Navigator.pushNamed] with arguments: pass data to the target screen.
/// - [Navigator.pushNamedAndRemoveUntil]: logout clears the entire stack and
///   lands on login, preventing Back from reaching any protected screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;

    // pushNamedAndRemoveUntil: removes ALL routes then pushes login.
    // (route predicate `(_) => false` means "remove everything").
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavNoteCard(
            title: 'Navigator 1: pushNamedAndRemoveUntil (logout)',
            body:
                'Logout calls pushNamedAndRemoveUntil with predicate '
                '(_) => false, which wipes the entire back-stack before '
                'pushing /login.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Explore',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _DemoTile(
            icon: Icons.person,
            label: 'Profile',
            subtitle: 'push → pop, returns edited name',
            onTap: () async {
              // pushNamed returns the value passed to Navigator.pop().
              final updatedName = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.profile, arguments: 'Alice') as String?;
              if (updatedName != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Name updated to "$updatedName"')),
                );
              }
            },
          ),
          _DemoTile(
            icon: Icons.settings,
            label: 'Settings',
            subtitle: 'push → pop',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _NavNoteCard extends StatelessWidget {
  const _NavNoteCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
