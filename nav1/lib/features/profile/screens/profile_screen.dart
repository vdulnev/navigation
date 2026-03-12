import 'package:flutter/material.dart';

import '../../../router/app_routes.dart';

/// Shows a user profile and lets the user navigate to Edit Profile.
///
/// Navigator 1 concepts demonstrated:
/// - Receiving route arguments via [ModalRoute.of].
/// - [Navigator.pushNamed] with arguments and awaiting a return value.
/// - [Navigator.pop] with a return value propagated back to Home.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Arguments are passed as pushNamed(arguments: 'Alice').
    final args = ModalRoute.of(context)?.settings.arguments;
    _name = args is String ? args : 'Unknown';
  }

  Future<void> _openEdit() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.editProfile, arguments: _name) as String?;
    if (result != null) {
      setState(() => _name = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: _openEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavNoteCard(
            title: 'Navigator 1: ModalRoute arguments + pop with value',
            body:
                'This screen reads its name argument from '
                'ModalRoute.of(context).settings.arguments.\n'
                'Pressing Back passes the (possibly edited) name back to Home '
                'via Navigator.pop(name).',
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            child: Text(
              _name.isNotEmpty ? _name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Name'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            // pop with the current name so Home can display a snackbar.
            onPressed: () => Navigator.of(context).pop(_name),
            child: const Text('Back (return name to Home)'),
          ),
        ],
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
