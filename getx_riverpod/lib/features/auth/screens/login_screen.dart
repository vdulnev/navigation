import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../providers/login_form_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen — no Form, no TextFormField, no GlobalKey, no setState.
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **All form state in Riverpod**: field values, per-field validation errors,
///   loading flag, and server error all live in [loginFormProvider]. The widget
///   is a plain [ConsumerWidget] — nothing to dispose.
///
/// • **GetX navigation**: `Get.back(result: true)` returns a value to the
///   caller that awaited `Get.toNamed(AppRoutes.login)`.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FlutterLogo(size: 64),
              const SizedBox(height: 32),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: form.emailError,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: notifier.setEmail,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  errorText: form.passwordError,
                ),
                obscureText: true,
                onChanged: notifier.setPassword,
              ),
              if (form.serverError != null) ...[
                const SizedBox(height: 12),
                Text(
                  form.serverError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: form.loading
                    ? null
                    : () async {
                        final ok = await notifier.submit();
                        if (ok && context.mounted) {
                          Get.back<bool>(result: true);
                        }
                      },
                child: form.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              const NavNoteCard(
                title: 'Riverpod form state — no Form/TextFormField',
                body:
                    'Email, password, field errors, loading, and server error '
                    'all live in loginFormProvider. The widget is a plain '
                    'ConsumerWidget — no GlobalKey, no controller, no setState.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
