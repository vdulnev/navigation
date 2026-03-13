import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../providers/login_state_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen — no Form, no TextFormField, no GlobalKey, no setState.
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **Sealed form state**: [LoginFormState] has three subclasses —
///   [LoginFormEditing] (clean), [LoginFormInvalid] (errors in one
///   [LoginFormErrors] object), and [LoginFormSubmitting]. The switch
///   expression is exhaustive; the compiler rejects missing cases.
///
/// • **GetX navigation**: `Get.back(result: true)` returns a value to the
///   caller that awaited `Get.toNamed(AppRoutes.login)`.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginStateProvider);
    final notifier = ref.read(loginStateProvider.notifier);

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
              // Exhaustive switch — compiler enforces all cases are handled.
              switch (state) {
                LoginFormEditing(:final email, :final password) => _EditingBody(
                  email: email,
                  password: password,
                  notifier: notifier,
                ),
                LoginFormInvalid(
                  :final email,
                  :final password,
                  error:final errors,
                ) =>
                  _EditingBody(
                    email: email,
                    password: password,
                    error: errors,
                    notifier: notifier,
                  ),
                LoginFormSubmitting() => const _SubmittingBody(),
              },
              const SizedBox(height: 16),
              const NavNoteCard(
                title: 'Riverpod: sealed form state (3 states)',
                body:
                    'LoginFormEditing (clean) → LoginFormInvalid (all errors '
                    'in one LoginFormErrors object) → LoginFormSubmitting '
                    '(spinner). Exhaustive switch rejects unhandled cases.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditingBody extends StatelessWidget {
  const _EditingBody({
    required this.email,
    required this.password,
    required this.notifier,
    this.error,
  });

  final String email;
  final String password;
  final LoginFormError? error;
  final LoginFormNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: const OutlineInputBorder(),
            errorText: 'Enter an email',
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.setEmail,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            errorText: 'Enter an password',
          ),
          obscureText: true,
          onChanged: notifier.setPassword,
        ),
        if (error is LoginServerError) ...[
          const SizedBox(height: 12),
          Text(
            error.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () async {
            final ok = await notifier.submit();
            if (ok && context.mounted) {
              Get.back<bool>(result: true);
            }
          },
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}

class _SubmittingBody extends StatelessWidget {
  const _SubmittingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          enabled: false,
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          enabled: false,
        ),
        SizedBox(height: 24),
        FilledButton(
          onPressed: null,
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ],
    );
  }
}
