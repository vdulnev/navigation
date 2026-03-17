import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/login_state_provider.dart';
import '../../../router/navigation_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen — pushed as a fullscreenDialog page over the shell.
///
/// Navigator 2 concept: this screen is a [MaterialPage] in the root
/// [Navigator]'s stack, visible only when [NavigationState.showLogin] is true.
///
/// Key difference from GoRouter: there is no [BuildContext.pop] with a return
/// value. Instead, [LoginFormNotifier.submit] sets auth state directly, then
/// calls [NavigationNotifier.onLoginSuccess] which updates [NavigationState]
/// and removes this page from the stack — all via Riverpod, no context needed.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginStateProvider);
    final notifier = ref.read(loginStateProvider.notifier);
    final nav = ref.read(navigationProvider.notifier);

    Future<void> onSubmit() async {
      if (await notifier.submit()) {
        nav.onLoginSuccess();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: BackButton(onPressed: nav.dismissLogin),
      ),
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
                title: 'Navigator 2: state-driven dismiss',
                body:
                    'submit() sets authProvider state directly, then calls '
                    'nav.onLoginSuccess(). NavigationState.showLogin becomes '
                    'false; the root Navigator diffs its page list and pops '
                    'this route — no context.pop() or return value needed.',
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
