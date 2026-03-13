import 'package:flutter/material.dart';

/// Annotation card shown on each screen to identify the Navigator 1 pattern
/// being demonstrated.
class NavNoteCard extends StatelessWidget {
  const NavNoteCard({super.key, required this.title, required this.body});

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
