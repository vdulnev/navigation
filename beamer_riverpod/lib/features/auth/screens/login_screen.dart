import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/login_state_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen — pushed as a fullscreenDialog via the root Navigator.
///
/// Beamer + Riverpod concepts demonstrated:
///
/// • **Pop before auth state change**: [AuthNotifier.login] validates
///   credentials but does NOT set `authProvider.state`. Navigator.pop(true)
///   runs first while the route stack is still intact, then
///   [AuthNotifier.setLoggedIn] fires to update reactive state.
///
/// • **Why auth state must come after pop**: setting `state = true` inside
///   `login()` would trigger BeamGuard re-evaluation and basket delegate
///   rebuilds before the modal is dismissed, causing visual glitches.
///
/// • **Beamer modal pop with value**: Beamer renders its [BeamPage]s as
///   standard [MaterialPage]s inside a [Navigator]. Therefore
///   `Navigator.of(context).pop(true)` works just like GoRouter's
///   `context.pop(true)` — the future returned by `pushNamed` resolves.
///
/// • **Sealed form state**: [LoginFormState] has four subclasses; the
///   exhaustive switch ensures all cases are handled at compile time.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginStateProvider);
    final notifier = ref.read(loginStateProvider.notifier);

    Future<void> onSubmit() async {
      if (await notifier.submit()) {
        if (context.mounted) {
          // Pop while the route stack is still intact (auth state not yet set).
          // Beamer pages are standard Navigator pages — pop(true) resolves
          // the future returned by pushNamed<bool>(AppRoutes.login).
          Navigator.of(context).pop(true);
          // Now update auth state. Fires after the modal is gone so that
          // BeamGuard and basket delegate see the correct stack.
          ref.read(authProvider.notifier).setLoggedIn();
        }
      }
    }

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
              switch (state) {
                LoginFormEditing(:final error) => _EditingBody(
                  notifier: notifier,
                  credentialsError: error,
                  onSubmit: onSubmit,
                ),
                LoginFormCorrect() => _EditingBody(
                  notifier: notifier,
                  onSubmit: onSubmit,
                ),
                LoginFormInvalid(:final error) => _EditingBody(
                  serverError: error,
                  notifier: notifier,
                  onSubmit: onSubmit,
                ),
                LoginFormSubmitting() => const _SubmittingBody(),
              },
              const SizedBox(height: 16),
              const NavNoteCard(
                title: 'Beamer: pop before setting auth state',
                body:
                    'auth.login() validates only — does not set authProvider '
                    'state. Navigator.of(context).pop(true) runs first '
                    '(stack intact), then setLoggedIn() fires. Beamer '
                    'delegates rebuild from the correct route, not /login.',
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
    required this.notifier,
    required this.onSubmit,
    this.credentialsError,
    this.serverError,
  });

  final LoginFormNotifier notifier;
  final Future<void> Function() onSubmit;
  final LoginCredentialsError? credentialsError;
  final LoginServerError? serverError;

  @override
  Widget build(BuildContext context) {
    final isCredentialsError = credentialsError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: const OutlineInputBorder(),
            errorText:
                isCredentialsError && (credentialsError!.email?.isEmpty ?? true)
                ? credentialsError!.emailError
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.setEmail,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            errorText:
                isCredentialsError &&
                    (credentialsError!.password?.isEmpty ?? true)
                ? credentialsError!.passwordError
                : null,
          ),
          obscureText: true,
          onChanged: notifier.setPassword,
        ),
        if (serverError != null) ...[
          const SizedBox(height: 12),
          Text(
            serverError!.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: onSubmit, child: const Text('Sign In')),
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
