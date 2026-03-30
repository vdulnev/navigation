import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/login_form_controller.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen — no Form, no TextFormField, no GlobalKey, no setState.
///
/// GetX concepts demonstrated:
///
/// • **Sealed form state**: [LoginFormState] has four subclasses —
///   [LoginFormEditing], [LoginFormCorrect], [LoginFormInvalid], and
///   [LoginFormSubmitting]. The switch expression is exhaustive.
///
/// • **Obx + `Rx<LoginFormState>`**: the entire form rebuilds whenever the
///   controller transitions between states.
///
/// • `Get.back(result: true)` returns a value to the caller that awaited
///   `Get.toNamed(AppRoutes.login)`.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginFormController>();
    controller.reset();

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
              Obx(() {
                final state = controller.state.value;
                return switch (state) {
                  LoginFormEditing(:final error) => _EditingBody(
                    controller: controller,
                    credentialsError: error,
                  ),
                  LoginFormCorrect() => _EditingBody(controller: controller),
                  LoginFormInvalid(:final error) => _EditingBody(
                    serverError: error,
                    controller: controller,
                  ),
                  LoginFormSubmitting() => const _SubmittingBody(),
                };
              }),
              const SizedBox(height: 16),
              const NavNoteCard(
                title: 'GetX: sealed form state (4 states)',
                body:
                    'LoginFormEditing (clean) → LoginFormCorrect (valid) '
                    '→ LoginFormInvalid (server error) → '
                    'LoginFormSubmitting (spinner). Exhaustive switch '
                    'rejects unhandled cases.',
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
    required this.controller,
    this.serverError,
    this.credentialsError,
  });

  final LoginServerError? serverError;
  final LoginCredentialsError? credentialsError;
  final LoginFormController controller;

  @override
  Widget build(BuildContext context) {
    final aServerError = serverError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: const OutlineInputBorder(),
            errorText: credentialsError?.emailError,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: controller.setEmail,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            errorText: credentialsError?.passwordError,
          ),
          obscureText: true,
          onChanged: controller.setPassword,
        ),
        if (aServerError != null) ...[
          const SizedBox(height: 12),
          Text(
            aServerError.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: controller.submit,
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
