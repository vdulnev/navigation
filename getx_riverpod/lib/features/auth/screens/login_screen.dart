import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../providers/auth_provider.dart';
import '../../../widgets/nav_note_card.dart';

/// Login screen presented as a slide-up modal (Transition.downToUp in app.dart).
///
/// GetX + Riverpod concepts demonstrated:
///
/// • **GetX navigation**: no BuildContext needed to dismiss — [Get.back] is
///   called globally. `Get.back(result: true)` returns a value to the caller
///   that awaited `Get.toNamed(AppRoutes.login)`.
///
/// • **Riverpod mutation**: login logic lives in [AuthNotifier]; the screen
///   calls `ref.read(authProvider.notifier).login(...)` and reacts to the
///   returned Future — no setState on global auth state.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      // Get.back(result: true) — caller awaits Get.toNamed and receives true.
      Get.back<bool>(result: true);
    } else {
      setState(() => _error = 'Invalid credentials. Try any non-empty values.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 64),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter an email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter a password' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                const NavNoteCard(
                  title: 'GetX: Get.back(result: value)',
                  body:
                      'Get.back(result: true) returns the value to the caller '
                      'that used await Get.toNamed(AppRoutes.login). No '
                      'BuildContext required — GetX holds a global navigator key.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
