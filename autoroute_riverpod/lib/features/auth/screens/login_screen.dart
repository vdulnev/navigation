import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/login_state_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen — pushed as a fullscreenDialog via
/// `context.router.push(LoginRoute())`.
///
/// AutoRoute concepts demonstrated:
///
/// * **context.router.pop(result)**: pops the route and resolves the
///   Future returned by `push<bool>(LoginRoute())` in the caller, or
///   calls `resolver.next()` in [AuthGuard].
///
/// * **No ordering constraint**: unlike GoRouter, AutoRoute does not
///   reconstruct its stack from the URL when auth state changes. So
///   [AuthNotifier.login] can set `state = true` directly inside the
///   async call — no need to pop first.
///
/// * **Sealed form state**: [LoginFormState] has four subclasses; the
///   exhaustive switch ensures all cases are handled at compile time.
@RoutePage()
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginStateProvider);
    final notifier = ref.read(loginStateProvider.notifier);

    Future<void> onSubmit() async {
      if (await notifier.submit()) {
        if (context.mounted) {
          // auth state is already true (set inside AuthNotifier.login).
          // Pop and pass true to the caller / AuthGuard resolver.
          context.router.pop(true);
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
                title: 'AutoRoute: router.pop(true) as return value',
                body:
                    'context.router.pop(true) resolves the Future from '
                    'push<bool>(LoginRoute()) in callers, and triggers '
                    'resolver.next() in AuthGuard. No URL reconstruction '
                    'issue — auth state is set before pop without side-effects.',
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
